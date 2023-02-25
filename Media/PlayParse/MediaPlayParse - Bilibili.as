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
bool enable_subtitle = true;
string subtitle_url = "https://subtitle.chen310.repl.co/subtitle?font=" + HostUrlEncode("微软雅黑") + "&font_size=30.0&alpha=0.8&is_reduce_comments=false&cid=";
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

uint gettid(string path) {
	array<string> urls = { 'www.bilibili.com/v/anime/serial', 'www.bilibili.com/v/anime/finish', 'www.bilibili.com/v/anime/information', 'www.bilibili.com/v/anime/offical', 'www.bilibili.com/anime', 'www.bilibili.com/movie', 'www.bilibili.com/v/guochuang/chinese', 'www.bilibili.com/v/guochuang/original', 'www.bilibili.com/v/guochuang/puppetry', 'www.bilibili.com/v/guochuang/motioncomic', 'www.bilibili.com/v/guochuang/information', 'www.bilibili.com/guochuang', 'www.bilibili.com/tv', 'www.bilibili.com/documentary', 'www.bilibili.com/v/douga/mad', 'www.bilibili.com/v/douga/mmd', 'www.bilibili.com/v/douga/voice', 'www.bilibili.com/v/douga/garage_kit', 'www.bilibili.com/v/douga/tokusatsu', 'www.bilibili.com/v/douga/acgntalks', 'www.bilibili.com/v/douga/other', 'www.bilibili.com/v/douga', 'www.bilibili.com/v/game/stand_alone', 'www.bilibili.com/v/game/esports', 'www.bilibili.com/v/game/mobile', 'www.bilibili.com/v/game/online', 'www.bilibili.com/v/game/board', 'www.bilibili.com/v/game/gmv', 'www.bilibili.com/v/game/music', 'www.bilibili.com/v/game/mugen', 'www.bilibili.com/v/game', 'www.bilibili.com/v/kichiku/guide', 'www.bilibili.com/v/kichiku/mad', 'www.bilibili.com/v/kichiku/manual_vocaloid', 'www.bilibili.com/v/kichiku/theatre', 'www.bilibili.com/v/kichiku/course', 'www.bilibili.com/v/kichiku', 'www.bilibili.com/v/music/original', 'www.bilibili.com/v/music/cover', 'www.bilibili.com/v/music/perform', 'www.bilibili.com/v/music/vocaloid', 'www.bilibili.com/v/music/live', 'www.bilibili.com/v/music/mv', 'www.bilibili.com/v/music/commentary', 'www.bilibili.com/v/music/tutorial', 'www.bilibili.com/v/music/other', 'www.bilibili.com/v/music', 'www.bilibili.com/v/dance/otaku', 'www.bilibili.com/v/dance/hiphop', 'www.bilibili.com/v/dance/star', 'www.bilibili.com/v/dance/china', 'www.bilibili.com/v/dance/three_d', 'www.bilibili.com/v/dance/demo', 'www.bilibili.com/v/dance', 'www.bilibili.com/v/cinephile/cinecism', 'www.bilibili.com/v/cinephile/montage', 'www.bilibili.com/v/cinephile/shortfilm', 'www.bilibili.com/v/cinephile/trailer_info', 'www.bilibili.com/v/cinephile', 'www.bilibili.com/v/ent/variety', 'www.bilibili.com/v/ent/talker', 'www.bilibili.com/v/ent/fans', 'www.bilibili.com/v/ent/celebrity', 'www.bilibili.com/v/ent', 'www.bilibili.com/v/knowledge/science', 'www.bilibili.com/v/knowledge/social_science', 'www.bilibili.com/v/knowledge/humanity_history', 'www.bilibili.com/v/knowledge/business', 'www.bilibili.com/v/knowledge/campus', 'www.bilibili.com/v/knowledge/career', 'www.bilibili.com/v/knowledge/design', 'www.bilibili.com/v/knowledge/skill', 'www.bilibili.com/v/knowledge', 'www.bilibili.com/v/tech/digital', 'www.bilibili.com/v/tech/application', 'www.bilibili.com/v/tech/computer_tech', 'www.bilibili.com/v/tech/industry', 'www.bilibili.com/v/tech', 'www.bilibili.com/v/information/hotspot', 'www.bilibili.com/v/information/global', 'www.bilibili.com/v/information/social', 'www.bilibili.com/v/information/multiple', 'www.bilibili.com/v/information', 'www.bilibili.com/v/food/make', 'www.bilibili.com/v/food/detective', 'www.bilibili.com/v/food/measurement', 'www.bilibili.com/v/food/rural', 'www.bilibili.com/v/food/record', 'www.bilibili.com/v/food', 'www.bilibili.com/v/life/funny', 'www.bilibili.com/v/life/parenting', 'www.bilibili.com/v/life/travel', 'www.bilibili.com/v/life/rurallife', 'www.bilibili.com/v/life/home', 'www.bilibili.com/v/life/handmake', 'www.bilibili.com/v/life/painting', 'www.bilibili.com/v/life/daily', 'www.bilibili.com/v/life', 'www.bilibili.com/v/car/racing', 'www.bilibili.com/v/car/modifiedvehicle', 'www.bilibili.com/v/car/newenergyvehicle', 'www.bilibili.com/v/car/touringcar', 'www.bilibili.com/v/car/motorcycle', 'www.bilibili.com/v/car/strategy', 'www.bilibili.com/v/car/life', 'www.bilibili.com/v/car', 'www.bilibili.com/v/fashion/makeup', 'www.bilibili.com/v/fashion/cos', 'www.bilibili.com/v/fashion/clothing', 'www.bilibili.com/v/fashion/trend', 'www.bilibili.com/v/fashion', 'www.bilibili.com/v/sports/basketball', 'www.bilibili.com/v/sports/football', 'www.bilibili.com/v/sports/aerobics', 'www.bilibili.com/v/sports/athletic', 'www.bilibili.com/v/sports/culture', 'www.bilibili.com/v/sports/comprehensive', 'www.bilibili.com/v/sports', 'www.bilibili.com/v/animal/cat', 'www.bilibili.com/v/animal/dog', 'www.bilibili.com/v/animal/reptiles', 'www.bilibili.com/v/animal/wild_animal', 'www.bilibili.com/v/animal/second_edition', 'www.bilibili.com/v/animal/animal_composite', 'www.bilibili.com/v/animal', 'www.bilibili.com/v/life/funny', 'www.bilibili.com/v/game/stand_alone' };
	array<uint> tids = { 33, 32, 51, 152, 13, 23, 153, 168, 169, 195, 170, 167, 11, 177, 24, 25, 47, 210, 86, 253, 27, 1, 17, 171, 172, 65, 173, 121, 136, 19, 4, 22, 26, 126, 216, 127, 119, 28, 31, 59, 30, 29, 193, 243, 244, 130, 3, 20, 198, 199, 200, 154, 156, 129, 182, 183, 85, 184, 181, 71, 241, 242, 137, 5, 201, 124, 228, 207, 208, 209, 229, 122, 36, 95, 230, 231, 232, 188, 203, 204, 205, 206, 202, 76, 212, 213, 214, 215, 211, 138, 254, 250, 251, 239, 161, 162, 21, 160, 245, 246, 246, 248, 240, 227, 176, 223, 157, 252, 158, 159, 155, 235, 249, 164, 236, 237, 238, 234, 218, 219, 222, 221, 220, 75, 217, 138, 17 };
	// array<string> names = { '连载动画', '完结动画', '资讯', '官方延伸', '番剧', '电影', '国产动画', '国产原创相关', '布袋戏', '动态漫·广播剧', '资讯', '国创', '电视剧', '纪录片', 'MAD·AMV', 'MMD·3D', '短片·手书·配音', '手办·模玩', '特摄', '动漫杂谈', '综合', '动画', '单机游戏', '电子竞技', '手机游戏', '网络游戏', '桌游棋牌', 'GMV', '音游', 'Mugen', '游戏', '鬼畜调教', '音MAD', '人力VOCALOID', '鬼畜剧场', '教程演示', '鬼畜', '原创音乐', '翻唱', '演奏', 'VOCALOID·UTAU', '音乐现场', 'MV', '乐评盘点', '音乐教学', '音乐综合', '音乐', '宅舞', '街舞', '明星舞蹈', '中国舞', '舞蹈综合', '舞蹈教程', '舞蹈', '影视杂谈', '影视剪辑', '小剧场', '预告·资讯', '影视', '综艺', '娱乐杂谈', '粉丝创作', '明星综合', '娱乐', '科学科普', '社科·法律·心理', '人 文历史', '财经商业', '校园学习', '职业职场', '设计·创意', '野生技能协会', '知识', '数码', '软件应用', '计算机技术', '科 工机械', '科技', '热点', '环球', '社会', '综合', '资讯', '美食制作', '美食侦探', '美食测评', '田园美食', '美食记录', '美食', '搞笑', '亲子', '出行', '三农', '家居房产', '手工', '绘画', '日常', '生活', '赛车', '改装玩车', '新能源车', '房车', '摩托车', '购车攻略', '汽车生活', '汽车', '美妆护肤', '仿妆cos', '穿搭', '时尚潮流', '时尚', '篮球', '足球', '健身', ' 竞技体育', '运动文化', '运动综合', '运动', '喵星人', '汪星人', '小宠异宠', '野生动物', '动物二创', '动物综合', '动物圈', '搞笑', '单机游戏' };
	for (uint i = 0; i < urls.size(); i++) {
		if (path.find(urls[i]) >= 0) {
			return tids[i];
		}
	}
	return 0;
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
			string isFromList = parse(path, "isfromlist");
			if (isFromList != "true") {
				MetaData["title"] = data["title"].asString();
			}
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
	if (enable_subtitle) {
		array<dictionary> subtitle;
		dictionary dic;
		dic["name"] = title;
		dic["url"] = subtitle_url + cid;
		subtitle.insertLast(dic);
		MetaData["subtitle"] = subtitle;
	}

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
	string value = HostRegExpParse(url, "\?" + key + "=([a-zA-Z0-9%]+)");
	if (!value.empty()) {
		return value;
	}
	value = HostRegExpParse(url, "&" + key + "=([a-zA-Z0-9%]+)");
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
	url += "mid=" + HostRegExpParse(path, "/([0-9]+)");
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
							video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?isfromlist=true";
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
	if (fid.empty()) {
		string mid = HostRegExpParse(path, "bilibili.com/([0-9]+)");
		if (mid.empty()) {
			mid = "" + uid;
		}
		string res = apiPost("/x/v3/fav/folder/created/list-all?up_mid=" + mid);
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
						video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?isfromlist=true";
						videos.insertLast(video);
					}
				}
			}
		}
	}
	return videos;
}

array<dictionary> followingLive(uint page) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string url = "https://api.live.bilibili.com/xlive/web-ucenter/user/following?page=" + page + "&page_size=10";
	string res = post(url);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() == 0) {
			JsonValue list = Root["data"]["list"];
			if (list.isArray()) {
				for (uint i = 0; i < list.size(); i++) {
					JsonValue item = list[i];
					// 未开播
					if (item["live_status"].asInt() == 0) {
						return videos;
					}
					dictionary video;
					video["title"] = item["uname"].asString() + " - " + item["title"].asString();
					video["url"] = "https://live.bilibili.com/" + item["roomid"].asInt();
					videos.insertLast(video);
				}
				if (page < Root["data"]["totalPage"].asInt()) {
					array<dictionary> videos2 = followingLive(page+1);
					for (uint i = 0; i < videos2.size(); i++) {
						videos.insertLast(videos2[i]);
					}
				}
			}
		}
	}
	return videos;
}

array<dictionary> Ranking(uint tid) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string res = apiPost("/x/web-interface/ranking/v2?rid=" + tid);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["list"];
		if (list.isArray()) {
			for (uint i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				video["title"] = item["title"].asString();
				video["duration"] = item["duration"].asInt() * 1000;
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?isfromlist=true";
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

string md2ss(string mdid) {
	JsonReader Reader;
	JsonValue Root;
	string ssid = "";
	string res = apiPost("/pgc/review/user?media_id=" + mdid);
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() == 0) {
			ssid = Root["result"]["media"]["season_id"].asString();
		}
	}
	return ssid;
}

// type: meida_id/season_id/ep_id
array<dictionary> Banggumi(string id, string type) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	if (type == "media_id") {
		id = md2ss(id);
		if (id.empty()) {
			return videos;
		}
		type = "season_id";
	}
	string url = "/pgc/view/web/season?" + type + "=" + id;
	string res = apiPost(url);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue episodes = Root["result"]["episodes"];
		if (episodes.isArray()) {
			for (uint i = 0; i < episodes.size(); i++) {
				JsonValue item = episodes[i];
				dictionary video;
				if (item["badge"].asString().empty()) {
					video["title"] = item["share_copy"].asString();
				} else {
					video["title"] = "【" + item["badge"].asString() + "】" + item["share_copy"].asString();
				}
				video["duration"] = item["duration"].asInt();
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?isfromlist=true";
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

array<dictionary> Recommend(uint page) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	const uint nums = 5;
	string url ="/x/web-interface/wbi/index/top/feed/rcmd?y_num=3&fresh_type=4&feed_version=V8&fresh_idx_1h="+page+"&fetch_row="+(3*page+1)+"&fresh_idx="+page+"&brush="+page+"&homepage_ver=1&ps=12&last_y_num=4&outside_trigger=";
	string res = apiPost(url);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["item"];
		if (list.isArray()) {
			for (uint i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				if (item["uri"].asString().find("live.bilibili.com") >= 0) {
					video["title"] = "【直播】" + item["owner"]["name"].asString() + " - " + item["title"].asString();
					video["url"] = item["uri"].asString();
				} else {
					video["title"] = item["title"].asString();
					video["duration"] = item["duration"].asInt() * 1000;
					video["url"] = item["uri"].asString();
				}
				videos.insertLast(video);
			}
		}
	}
	if (page < nums) {
		array<dictionary> videos2 = Recommend(page+1);
		for (uint i = 0; i < videos2.size(); i++) {
			videos.insertLast(videos2[i]);
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
		MetaData["title"] = Root["data"]["anchor_info"]["base_info"]["uname"].asString() + " - " +  data["title"].asString();
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
	if (path.find("link.bilibili.com") >= 0 && path.find("/user-center/follow") >= 0) {
		return true;
	}
	if (path.find("www.bilibili.com") >= 0 && HostRegExpParse(path, "www.bilibili.com/([a-zA-Z0-9]+)").empty()) {
		return true;
	}
	if (path.find("bangumi/media/md") >= 0) {
		return true;
	}
	if (path.find("bangumi/play/") >= 0) {
		return true;
	}
	if (gettid(path) > 0) {
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
	if (path.find("link.bilibili.com") >= 0 && path.find("/user-center/follow") >= 0) {
		return followingLive(1);
	}
	if (path.find("www.bilibili.com") >= 0 && HostRegExpParse(path, "www.bilibili.com/([a-zA-Z0-9]+)").empty()) {
		return Recommend(1);
	}
	if (path.find("bangumi/media/md") >= 0) {
		return Banggumi(HostRegExpParse(path, "bangumi/media/md([0-9]+)"), "media_id");
	}
	if (path.find("bangumi/play/ep") >= 0) {
		return Banggumi(HostRegExpParse(path, "bangumi/play/ep([0-9]+)"), "ep_id");
	}
	if (path.find("bangumi/play/ss") >= 0) {
		return Banggumi(HostRegExpParse(path, "bangumi/play/ss([0-9]+)"), "season_id");
	}
	uint tid = gettid(path);
	if (tid > 0) {
		return Ranking(tid);
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
