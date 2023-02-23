/*
	Bilibili media parse
	author: chen310
	link: https://github.com/chen310/BilibiliPotPlayer
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
//------------------------------------------------------------------------------------------------
// bool PlayitemCheck(const string &in)					-> check playitem
// array<dictionary> PlayitemParse(const string &in)	-> parse playitem
// bool PlaylistCheck(const string &in)					-> check playlist
// array<dictionary> PlaylistParse(const string &in)	-> parse playlist


bool debug = false;
string cookie = "";
int uid = 0;
// 是否可选择画质
bool enable_qualities = true;

void OnInitialize() {
	HostSetUrlHeaderHTTP("bilivideo.com", "Referer: https://www.bilibili.com\r\n");
	HostSetUrlHeaderHTTP("bilivideo.cn", "Referer: https://www.bilibili.com\r\n");
	HostSetUrlHeaderHTTP("bilibili.com", "Referer: https://www.bilibili.com\r\n");
}

string host = "https://api.bilibili.com";

string GetTitle() {

	return "Bilibili";
}

string GetVersion() {

	return "1.3";
}

string GetDesc() {

	return "https://www.bilibili.com";
}

string GetLoginTitle()
{
	return "请输入Bilibili Cookie";
}

string GetLoginDesc()
{
	return "请输入Bilibili Cookie";
}

string GetUserText()
{
	return "这里放空";
}

string GetPasswordText()
{
	return "Cookie:";
}

string ServerCheck(string User, string Pass) {
	if (Pass.empty()) {
		return "请输入Cookie";
	}
	string info = "";
	JsonReader reader;
	JsonValue root;
	string res = post("https://api.bilibili.com/x/web-interface/nav");
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() != 0) {
			return "无法获取用户信息";
		}
		JsonValue data = root["data"];
		if (data.isObject()) {
			info += "用户名: " + data["uname"].asString() + "\n";
			info += "uid: " + data["mid"].asInt() + "\n";
			info += "等级: " + data["level_info"]["current_level"].asString() + "\n";
			info += "硬币: " + data["money"].asFloat() + "\n";
		}
	}
	return info;
}

string ServerLogin(string User, string Pass)
{
	if (Pass.empty()) return "cookie 为空";
	handleCookie(Pass);
	return "200 ok";
}

void handleCookie(string full_cookie) {
	array<string> cookies = full_cookie.split(";");
	for (uint i=0; i < cookies.length(); i++) {
		int pos = cookies[i].find("SESSDATA");
		if (pos >= 0) {
			cookie = cookies[i].substr(pos);
		}
		if (cookies[i].find("DedeUserID=") >= 0) {
			uid = parseInt(cookies[i].split("=")[1]);
		}
	}
}

void log(string item) {
	if (!debug) {
		return;
	}
	HostOpenConsole();
	HostPrintUTF8(item);
}

void log(string item, string info) {
	if (!debug) {
		return;
	}
	HostOpenConsole();
	if (item.empty()) {
		HostPrintUTF8(info);
	} else {
		HostPrintUTF8(item + ": " + info);
	}
}

void log(string item, int info) {
	if (!debug) {
		return;
	}
	HostOpenConsole();
	if (item.empty()) {
		HostPrintUTF8("" + info);
	} else {
		HostPrintUTF8(item + ": " + info);
	}
}

string post(string url, string data="") {
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	string Headers = "Referer: https://www.bilibili.com\r\n";
	Headers += "User-Agent: " + UserAgent + "\r\n";
	if (!cookie.empty()) {
		Headers += "Cookie: " + cookie + "\r\n";
	}
	log("request", url);
	return HostUrlGetStringWithAPI(url, UserAgent, Headers, data, true);
}

string apiPost(string api, string data="") {
	return post(host + api);
}

string Video(string bvid, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	int aid;
	int cid;
	string title;
	string owner;
	string url;
	JsonReader reader;
	JsonValue root;
	int qn = 120;
	string quality;

	res = apiPost("/x/web-interface/view?bvid=" + bvid);
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data = root["data"];
			aid = data["aid"].asInt();
			cid = data["cid"].asInt();
			title = data["title"].asString();
			owner = data["owner"]["name"].asString();
			MetaData["title"] = data["title"].asString();
			MetaData["SourceUrl"] = path;			
		} else {
			return url;
		}
	}

	res = apiPost("/x/player/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + qn + "&fnval=128&fourk=1");
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data = root["data"];
			JsonValue urls = data["durl"];
			if (data["durl"].isArray()) {
				url = data["durl"][0]["url"].asString();
				qn = root["data"]["quality"].asInt();
				JsonValue qualities = root["data"]["accept_quality"];
				if (enable_qualities && @QualityList !is null) {
					for (uint i = 0; i < qualities.size(); i++) {			
						int quality = qualities[i].asInt();
						log("qn", quality);
						dictionary qualityitem;
						if (quality == qn) {
							qualityitem["url"] = url;
						} else {
							string quality_res = apiPost("/x/player/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + quality + "&fnval=128&fourk=1");
							JsonValue temp;
							if (reader.parse(quality_res, temp) && temp.isObject()) {
								if (temp["code"].asInt() != 0) {
									continue;
								}
								JsonValue qyality_data = temp["data"]["durl"];
								if (qyality_data.isArray()) {
									qualityitem["url"] = qyality_data[0]["url"].asString();
								}
							}
						}
						qualityitem["quality"] = getVideoquality(quality);
						qualityitem["qualityDetail"] = qualityitem["quality"];
						qualityitem["itag"] = getVideoItag(quality);
						QualityList.insertLast(qualityitem);
					}
				}
			}
			else if (data["dash"].isObject()) {
				if (data["dash"]["video"].isArray()) {
					url = data["dash"]["video"][0]["baseUrl"].asString();
				}
			}
			quality = data["quality"].asInt();
		} else {
			return url;
		}
	}
	array<dictionary> subtitle;
	dictionary dic;
	dic["name"] = title;
	// dic["url"] = "http://127.0.0.1:12345/subtitle?cid=" + cid;
	dic["url"] = "https://subtitle.chen310.repl.co/subtitle?cid=" + cid;
	subtitle.insertLast(dic);
	MetaData["subtitle"] = subtitle;
	log("--------------------------------------------------");
	log("标题", title);
	log("创建者", owner);
	log("AID", aid);
	log("BVID", bvid);
	log("CID", cid);
	log("QUALITY", quality);
	log("URL", url);
	log("");

	return url;
}

string parse(string url, string key, string defaultValue="") {
	string value = HostRegExpParse(url, "\?" + key + "=([a-zA-Z0-9]+)");
	if (!value.empty()) {
		return value;
	}
	value = HostRegExpParse(url, "&" + key + "=([a-zA-Z0-9]+)");
	if (!value.empty()) {
		return value;
	}

	value = defaultValue;
	return value;
}

string parseBVId(string url) {
	string bvid = HostRegExpParse(url, "(BV[a-zA-Z0-9]+)");
	return bvid;
}

string parseUId(string url) {
	string uid = HostRegExpParse(url, "/([0-9]+)");
	return uid;
}

int parseTime(string s) {
	array<string> strs = s.split(":");
	int t = 0;
	if (strs.length() == 1) {
		t = parseInt(strs[0]) * 1000;
	}
	else if (strs.length() == 2) {
		t = (parseInt(strs[0])*60 + parseInt(strs[1]))*1000;
	} else if (strs.length() == 3) {
		t = (parseInt(strs[0])*3600 + parseInt(strs[1])*60 + parseInt(strs[2]))*1000;
	}
	return t;
}

array<dictionary> spaceVideo(string path) {
	int ps = 50;
	string url = "/x/space/wbi/arc/search?";
	url += "mid=" + parseUId(path);
	url += "&ps=" + ps;
	url += "&tid=" + parse(path, "tid", "0");
	url += "&pn=1";
	url += "&keyword=" + parse(path, "keyword");
	url += "&order=" + parse(path, "order", "pubdate");
	string res = apiPost(url);
	array<dictionary> videos;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				JsonValue data = Root["data"]["list"]["vlist"];
				if (data.isArray()) {
					for (uint i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							video["title"] = item["title"].asString();
							video["duration"] = parseTime(item["length"].asString());
							video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
							videos.insertLast(video);
						}
					}
				}
			}
		}
	}
	return videos;
}

string parseFid(string path) {
	string fid = parse(path, "fid");
	if (fid.empty()) {
		fid = parse(path, "searchFid");
	}
	if (fid.empty()) {
		fid = HostRegExpParse(path, "/medialist/detail/ml([0-9]+)");
	}
	return fid;
}

array<dictionary> FavList(string path) {
	JsonReader Reader;
	array<dictionary> videos;
	string fid = parseFid(path);
	log("fid", fid);
	if (fid.empty()) {
		string res = apiPost("/x/v3/fav/folder/created/list-all?up_mid=" + uid);
		if (res.empty()) {
			return videos;
		}
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				JsonValue data = Root["data"]["list"];
				if (data.isArray()) {
					fid = "" + data[0]["id"].asInt();
				}
			}
		}
	}
	if (fid.empty()) {
		return videos;
	}
	string url = "";
	string ftype = parse(path, "ftype");
	// 订阅和收藏
	if (ftype == "collect") {
		url = "/x/space/fav/season/list?season_id=" + fid + "&pn=1&ps=20";
	} else {
		url = "/x/v3/fav/resource/list?media_id=" + fid + "&pn=1&ps=20";
		url += "&keyword=" + parse(path, "keyword");
		url += "&order=" + parse(path, "order", "mtime");
		// url += "&type=" + parse(path, "type", "0");
		url += "&tid=" + parse(path, "tid", "0");
	}
	string res = apiPost(url);
	if (res.empty()) {
		return videos;
	}
	JsonValue Root;
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() == 0) {
			JsonValue data = Root["data"]["medias"];
			if (data.isArray()) {
				for (uint i = 0; i < data.size(); i++) {
					JsonValue item = data[i];
					if (item.isObject()) {
						dictionary video;
						video["title"] = item["title"].asString();
						video["duration"] = item["duration"].asInt() * 1000;
						video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
						videos.insertLast(video);
					}
				}
			}
		}
	}
	return videos;
}

int getItag(int qn) {
	array<int> qns = {10000, 400, 250, 150, 80};
	int idx = qns.find(qn);
	if (idx >= 0) {
		return idx;
	}
	return qn;
}

int getVideoItag(int qn) {
	array<int> qns = {127, 126, 125, 120, 116, 112, 80, 74, 64, 32, 16, 6};
	int idx = qns.find(qn);
	if (idx >= 0) {
		return idx;
	}
	return qn;
}

string getVideoquality(int qn) {
	array<int> qns = {127, 126, 125, 120, 116, 112, 80, 74, 64, 32, 16, 6};
	array<string> qualities = {"8K 超高清", "杜比视界", "HDR 真彩色", "4K 超清", "1080P60 高帧率", "1080P+ 高码率", "1080P 高清", "720P60 高帧率", "720P 高清", "480P 清晰", "360P 流畅", "240P 极速"};
	int idx = qns.find(qn);
	if (idx >= 0) {
		return qualities[idx];
	}
	return "未知";
}

string Live(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string url = "";
	int room_id = 0;
	int qn = 10000;
	string res = post("https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom?room_id=" + id);
	JsonReader Reader;
	JsonValue Root;
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return "";
		}
		JsonValue data = Root["data"]["room_info"];
		MetaData["title"] = data["title"].asString();
		MetaData["SourceUrl"] = path;
		room_id = data["room_id"].asInt();
	}
	res = post("https://api.live.bilibili.com/xlive/web-room/v1/playUrl/playUrl?cid=" + room_id + "&platform=web&qn=" + qn + "&https_url_req=1&ptype=16");
	if (Reader.parse(res, Root) && Root.isObject()) {
		qn = Root["data"]["current_qn"].asInt();
		if (Root["code"].asInt() != 0) {
			return "";
		}
		JsonValue data = Root["data"]["durl"];
		if (data.isArray()) {
			url = data[0]["url"].asString();
			JsonValue qualities = Root["data"]["quality_description"];
			if (enable_qualities && @QualityList !is null) {
				for (uint i = 0; i < qualities.size(); i++) {
					int quality = qualities[i]["qn"].asInt();
					dictionary qualityitem;
					if (quality == qn) {
						qualityitem["url"] = url;
					} else {
						string quality_res = post("https://api.live.bilibili.com/xlive/web-room/v1/playUrl/playUrl?cid=" + room_id + "&platform=web&qn=" + quality + "&https_url_req=1&ptype=16");
						JsonValue temp;
						if (Reader.parse(quality_res, temp) && temp.isObject()) {
							if (temp["code"].asInt() != 0) {
								continue;
							}
							JsonValue qyality_data = temp["data"]["durl"];
							if (qyality_data.isArray()) {
								qualityitem["url"] = qyality_data[0]["url"].asString();
							}
						}
					}
					qualityitem["quality"] = qualities[i]["desc"].asString();
					qualityitem["qualityDetail"] = qualities[i]["desc"].asString();
					qualityitem["itag"] = getItag(quality);
					QualityList.insertLast(qualityitem);
				}
			}
		}
	}
	return url;

}

bool PlayitemCheck(const string &in path) {
	if (path.find("bilibili.com") < 0) {
		return false;
	}

	if (path.find("/video/BV") >= 0) {
		return true;
	}

	if (path.find("live.bilibili.com") >= 0) {
		return true;
	}

	return false;
}

bool PlaylistCheck(const string &in path) {
	if (path.find("bilibili.com") < 0) {
		return false;
	}
	if (path.find("space.bilibili.com") >= 0) {
		if (path.find("/video") >= 0) {
			return true;
		}
		else if (path.find("/audio") >= 0) {
			return true;
		}
		else if (path.find("/favlist") >= 0) {
			return true;
		}
		else if (HostRegExpParse(path, "/([0-9]+)/[a-zA-Z0-9]").empty()) {
			return true;
		}
		else {
			return false;
		}
	}
	if (path.find("/medialist/detail/ml") >= 0) {
		return true;
	}

	return false;
}

array<dictionary> PlaylistParse(const string &in path) {
	array<dictionary> result;

	if (path.find("space.bilibili.com") >= 0) {
		if (path.find("/video") >= 0) {
			return spaceVideo(path);
		}
		else if (path.find("/audio") >= 0) {
			
		}
		else if (path.find("/favlist") >= 0) {
			return FavList(path);
		}
		else if (HostRegExpParse(path, "/([0-9]+)/[a-zA-Z0-9]").empty()) {
			return spaceVideo(path);
		}
	}
	if (path.find("/medialist/detail/ml") >= 0) {
		return FavList(path);
	}

	return result;
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	if (path.find("/video/BV") >= 0) {
		string bvid = parseBVId(path);
		return Video(bvid, path, MetaData, QualityList);
	}
	if (path.find("live.bilibili.com") >= 0) {
		string id = HostRegExpParse(path, "live.bilibili.com/([0-9]+)");
		if (!id.empty()) {
			return Live(id, path, MetaData, QualityList);
		}
	}

	return path;
}
