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

// ******************** 设置开始 ********************

bool debug = true;
string cookie = "";

// ******************** 设置结束 ********************

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
	cookie = Pass;
	if (cookie.empty()) return "cookie 为空";
	return "200 ok";
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
	log("post", url);
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
	int qn = 127;
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

	res = apiPost("/x/player/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + qn + "&otype=json&fnval=128");
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data = root["data"];
			JsonValue urls = data["durl"];
			if (data["durl"].isArray()) {
				url = data["durl"][0]["url"].asString();
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
	dic["url"] = "http://127.0.0.1:12345/subtitle?cid=" + cid;
	subtitle.insertLast(dic);
	MetaData["subtitle"] = subtitle;
	log("video aid", aid);
	log("video cid", cid);
	log("video title", title);
	log("video owner", owner);
	log("video quality", quality);
	log("video url", url);

	return url;
}

string parse(string url, string key) {
	string value = HostRegExpParse(url, "\?" + key + "=([a-zA-Z0-9]+)");
	if (!value.empty()) {
		return value;
	}
	value = HostRegExpParse(url, "&" + key + "=([a-zA-Z0-9]+)");
	if (!value.empty()) {
		return value;
	}
	return "";
}

string parse(string url, string key, string defaultValue) {
	string value = parse(url, key);
	if (value.empty()) {
		value = defaultValue;
	}
	return value;
}

string parseBVId(string url) {
	string bvid = HostRegExpParse(url, "(BV[a-zA-Z0-9]+)");
	return bvid;
}

string parseUId(string url) {
	string uid = HostRegExpParse(url, "/([0-9]+)/");
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

// array<dictionary> spaceVideo(string uid, int ps, string tid, int pn, string kw, string order) {
array<dictionary> spaceVideo(string path) {
	int ps = 50;
	string url = "/x/space/wbi/arc/search?";
	url += "mid=" + parseUId(path);
	url += "&ps=" + ps;
	url += "&tid=" + parse(path, "tid" "0");
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

bool PlayitemCheck(const string &in path) {
	if (path.find("bilibili.com") < 0) {
		return false;
	}

	if (path.find("/video/BV") >= 0) {
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
	}

	return result;
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	if (path.find("/video/BV") >= 0) {
		string bvid = parseBVId(path);
		return Video(bvid, path, MetaData, QualityList);
	}

	return path;
}
