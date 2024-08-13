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

Config ConfigData;

void OnInitialize() {
	HostSetUrlHeaderHTTP("bilivideo.com", "Referer: https://www.bilibili.com\r\n");
	HostSetUrlHeaderHTTP("bilivideo.cn", "Referer: https://www.bilibili.com\r\n");
	HostSetUrlHeaderHTTP("bilibili.com", "Referer: https://www.bilibili.com\r\n");
}

string host = "https://api.bilibili.com";
string mixin_key;

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
	return "请输入配置文件所在位置";
}

string GetLoginDesc()
{
	return "请输入配置文件所在位置";
}

string GetUserText()
{
	return "配置文件路径";
}

string GetPasswordText()
{
	return "";
}

string ServerCheck(string User, string Pass) {
	if (User.empty()) {
		return "未填写配置文件路径";
	}
	if (!isFileExists(User)) {
		return "配置文件不存在";
	}
	if (ConfigData.cookie.empty()) {
		return "未填写cookie";
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
	if (User.empty()) {
		return "路径不可为空";
	}
	if (!isFileExists(User)) {
		return "配置文件不存在";
	}
	ConfigData = ReadConfigFile(User);
	if (ConfigData.debug) {
		HostOpenConsole();
	}

	return "配置文件读取成功，修改完配置文件后需要重启 PotPlayer 才能生效";
}

bool isFileExists(string path) {
	return HostFileOpen(path) > 0;
}

class Config {
	string fullConfig;
	string cookie;
	int uid = 0;
	bool danmakuEnable = true;
	string danmakuServer;
	string danmakuFont;
	float danmakuFontSize = 30.0;
	float danmakuOpacity = 0.8;
	float danmakuDisplayArea = 0.8;
	float danmakuStayTime = 15.0;
	bool showRecommendedVideos = true;
	bool debug = false;

	string danmakuUrl;
	string subtitleUrl;
};

Config ReadConfigFile(string file) {
	Config config;
	config.fullConfig = HostFileRead(HostFileOpen(file), 10000);
	JsonReader reader;
	JsonValue root;
	if (reader.parse(config.fullConfig, root) && root.isObject()) {
		if (root["cookie"].isString() && !root["cookie"].asString().empty()) {
			config.cookie = root["cookie"].asString();
			array<string> cookies = config.cookie.split(";");
			for (uint i=0; i < cookies.length(); i++) {
				if (cookies[i].find("DedeUserID=") >= 0) {
					ConfigData.uid = parseInt(cookies[i].split("=")[1]);
					break;
				}
			}
		}
		if (root["danmaku"].isObject()) {
			JsonValue danmaku = root["danmaku"];
			if (danmaku["enable"].isBool()) {
				config.danmakuEnable = danmaku["enable"].asBool();
			}
			if (danmaku["server"].isString() && !danmaku["server"].asString().empty()) {
				config.danmakuServer = danmaku["server"].asString();
			}
			if (danmaku["font"].isString()) {
				config.danmakuFont = danmaku["font"].asString();
			}
			if (danmaku["fontSize"].isNumeric()) {
				config.danmakuFontSize = danmaku["fontSize"].asFloat();
			}
			if (danmaku["opacity"].isNumeric()) {
				config.danmakuOpacity = danmaku["opacity"].asFloat();
			}
			if (danmaku["displayArea"].isNumeric()) {
				config.danmakuDisplayArea = danmaku["displayArea"].asFloat();
			}
			if (danmaku["stayTime"].isNumeric()) {
				config.danmakuStayTime = danmaku["stayTime"].asFloat();
			}
		}
		if (root["showRecommendedVideos"].isBool()) {
			config.showRecommendedVideos = root["showRecommendedVideos"].asBool();
		}
		if (root["debug"].isBool()) {
			config.debug = root["debug"].asBool();
		}
		if (!config.danmakuServer.empty()) {
			config.danmakuUrl = config.danmakuServer +  "/subtitle?font=" + HostUrlEncode(config.danmakuFont) + "&font_size=" + config.danmakuFontSize + "&alpha=" + config.danmakuOpacity + "&display_area=" + config.danmakuDisplayArea + "&duration_marquee=" + config.danmakuStayTime + "&duration_still=" + config.danmakuStayTime + "&cid=";
			config.subtitleUrl = config.danmakuServer + "/subtitle?url=";
		}
	}
	return config;
}

uint status = 0;
string GetStatus()
{
	string info = "";

	switch (status)
	{
	case  1:
		info = "Parsing bilibili playlist";
		break;
	case  2:
		info = "Parsing bilibili video/audio";
		break;
	case  3:
		info = "Parsing bilibili playback link";
		break;
	default:
		info = "Waiting for parsing";
	}

	return info;
}

void log(string item) {
	if (!ConfigData.debug) {
		return;
	}
	HostPrintUTF8(item);
}

void log(string item, string info) {
	log(item + ": " + info);
}

void log(string item, int info) {
	log(item + ": " + info);
}

string post(string url, string data="") {
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	string Headers = "Referer: https://www.bilibili.com\r\n";
	if (!ConfigData.cookie.empty()) {
		Headers += "Cookie: " + ConfigData.cookie + "\r\n";
	}
	log("request", url);
	return HostUrlGetStringWithAPI(url, UserAgent, Headers, data, true);
}

string apiPost(string api, string data="") {
	return post(host + api);
}

string getMixinKey() {
	JsonReader Reader;
	JsonValue Root;
	string key = "";
	string res = apiPost("/x/web-interface/nav");
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].isInt()) {
			JsonValue wbi_img = Root["data"]["wbi_img"];
			string img_url = wbi_img["img_url"].asString();
			string sub_url = wbi_img["sub_url"].asString();
			array<string> parts = img_url.split("/");
			string img_value = parts[parts.length() - 1].split(".")[0];
			parts = sub_url.split("/");
			string sub_value = parts[parts.length() - 1].split(".")[0];
			string ae = img_value + sub_value;
			array<int> oe = {46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49, 33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40, 61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11, 36, 20, 34, 44, 52};
			for (uint i = 0; i < oe.length(); i++) {
				key += ae.substr(oe[i], 1);
			}
		}
	}
	if (key.empty()) {
		return key;
	}
	return key.substr(0,32);
}

string encWbi(string params) {
	if (mixin_key.empty()) {
		mixin_key = getMixinKey();
	}
	array<string> lst = params.split("&");
	lst.sortAsc();
	string newParams;
	for (uint i = 0; i < lst.length(); i++)
	{
		newParams += lst[i];
		if (i != lst.length() - 1)
			newParams += "&";
	}
	return HostHashMD5(newParams + mixin_key);
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

// 分P
array<dictionary> VideoPages(string id) {
	array<dictionary> videos;
	if (id.empty()) {
		return videos;
	}
	string res;
	if (id.find("BV") == 0) {
		res = apiPost("/x/web-interface/view?bvid=" + id);
	} else {
		res = apiPost("/x/web-interface/view?aid=" + id);
	}
	string bvid;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				bvid = Root["data"]["bvid"].asString();
				JsonValue data = Root["data"]["pages"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							video["title"] = item["part"].asString();
							video["duration"] = item["duration"].asInt() * 1000;
							video["url"] = "https://www.bilibili.com/video/" + bvid + "?p=" + item["page"].asInt();
							video["thumbnail"] = item["first_frame"].asString();
							video["author"] = Root["data"]["owner"]["name"].asString();
							videos.insertLast(video);
						}
					}
				}
			}
		}
	}
	if (videos.length() >= 2 || !ConfigData.showRecommendedVideos) {
		return videos;
	}
	res = apiPost("/x/web-interface/archive/related?bvid=" + bvid);
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				JsonValue data = Root["data"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							video["title"] = item["title"].asString();
							video["duration"] = item["duration"].asInt() * 1000;
							video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
							video["thumbnail"] = item["pic"].asString();
							video["author"] = item["owner"]["name"].asString();
							videos.insertLast(video);
						}
					}
				}
			}
		}
	}
	return videos;
}

string makeWebUrl(string path) {
	array<string> strs = path.split("?");
	if (strs.length() <= 1) {
		return path;
	}
	string url = strs[0];
	string p = parse(path, "p");
	if (p.empty() || p == "1") {
		return url;
	}
	return url + "?p=" + p;
}

string Video(string bvid, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	log("--------------------------------------------------");
	string res;
	string aid;
	string title;
	string url;
	JsonReader reader;
	JsonValue root;
	int qn = 127;
	string cid = parse(path, "cid");
	int p = parseInt(parse(path, "p", "1"));
	bool ispgc = false;
	string webUrl = path;
	array<dictionary> subtitle;
	res = apiPost("/x/web-interface/view?bvid=" + bvid);
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data = root["data"];
			aid = data["aid"].asString();
			if (!cid.empty()) {
				for (int i = 0; i < data["pages"].size(); i++) {
					if (data["pages"][i]["cid"].asString() == cid) {
						p = i + 1;
						break;
					}
				}
			}
			cid = data["pages"][p-1]["cid"].asString();
			title = data["pages"][p-1]["part"].asString();
			MetaData["author"] = data["owner"]["name"].asString();
			MetaData["viewCount"] = data["stat"]["view"].asString();
			MetaData["likeCount"] = data["stat"]["like"].asString();
			MetaData["thumbnail"] = data["pic"].asString();
			string desc = data["desc"].asString();
			if (desc.empty()) {
				MetaData["content"] = title;
			} else {
				MetaData["content"] = title + " | " + desc;
			}
			JsonValue redirect_url = data["redirect_url"];
			if (redirect_url.isString() && redirect_url.asString().find("bangumi/play/ep") >= 0) {
				webUrl = redirect_url.asString();
				ispgc = true;
			}
			MetaData["webUrl"] = makeWebUrl(webUrl);
			if (ConfigData.danmakuEnable) {
				dictionary dic;
				dic["name"] = "【弹幕】" + title;
				dic["url"] = ConfigData.danmakuUrl + cid;
				subtitle.insertLast(dic);
			}
		} else {
			return url;
		}
	}

	res = apiPost("/x/player/v2?bvid=" + bvid + "&cid=" + cid);
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data = root["data"];
			if (ConfigData.danmakuEnable) {
				JsonValue subs;
				subs = root["data"]["subtitle"]["subtitles"];
				if (subs.isArray()) {
					for (int i = 0; i < subs.size(); i++) {
						JsonValue sub = subs[i];
						dictionary dic;
						dic["name"] = "【字幕】" + sub["lan_doc"].asString();
						if (sub["subtitle_url"].asString().find("http") == 0) {
							dic["url"] = ConfigData.subtitleUrl + sub["subtitle_url"].asString();
						} else {
							dic["url"] = ConfigData.subtitleUrl + "http:" + sub["subtitle_url"].asString();
						}
						subtitle.insertLast(dic);
					}
				}
				if (!subtitle.empty()) {
					MetaData["subtitle"] = subtitle;
				}
			}
			JsonValue points = data["view_points"];
			if (points.isArray()) {
				array<dictionary> chapt;
				for (int i = 0; i < points.size(); i++) {
					JsonValue point = points[i];
					dictionary item;
					item["title"] = point["content"].asString();
					item["time"] = formatUInt(point["from"].asInt() * 1000);
					chapt.insertLast(item);
				}
				if (!chapt.empty() && (@QualityList !is null)) {
					MetaData["chapter"] = chapt;
				}
			}
		} else {
			return url;
		}
	}
	status = 3;
	if (ispgc) {
		res = apiPost("/pgc/player/web/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + qn + "&fnval=4048&fourk=1");
	} else {
		res = apiPost("/x/player/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + qn + "&fnval=4048&fourk=1");
	}
	if (res.empty()) {
		return url;
	}
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() == 0) {
			JsonValue data;
			if (ispgc) {
				data = root["result"];
				JsonValue clip_info_list = data["clip_info_list"];
				if (clip_info_list.isArray() && clip_info_list.size() > 0) {
					array<dictionary> chapt;
					for (int i = 0; i < clip_info_list.size(); i++) {
						JsonValue chapter = clip_info_list[i];
						if (chapter.isObject()) {
							if (chapter["clipType"].asString() == "CLIP_TYPE_OP") {
								dictionary startItem;
								startItem["title"] = "哔哩哔哩-片头";
								startItem["time"] = formatUInt((chapter["start"].asInt() == 0 ? chapter["start"].asInt() : chapter["start"].asInt() + 1) * 1000);
								chapt.insertLast(startItem);
								dictionary contentItem;
								contentItem["title"] = "哔哩哔哩-正片";
								contentItem["time"] = formatUInt((chapter["end"].asInt() - 1) * 1000);
								chapt.insertLast(contentItem);
							} else if (chapter["clipType"].asString() == "CLIP_TYPE_ED") {
								dictionary endItem;
								endItem["title"] = "哔哩哔哩-片尾";
								endItem["time"] = formatUInt((chapter["start"].asInt() + 1) * 1000);
								chapt.insertLast(endItem);
							}
						}
					}
					if (!chapt.empty() && (@QualityList !is null)) {
						MetaData["chapter"] = chapt;
					}
				}
			} else {
				data = root["data"];
			}

			if (data["dash"].isObject()) {
				JsonValue videos = data["dash"]["video"];
				if (@QualityList !is null) {
					for (int i = 0; i < videos.size(); i++) {
						int quality = videos[i]["id"].asInt();
						dictionary qualityitem;
						int codecid = videos[i]["codecid"].asInt();
						url = videos[i]["baseUrl"].asString();
						qualityitem["url"] = url;
						int itag = videos[i]["id"].asInt() * 10 + codecid;
						int trueitag = getTrueItag(itag);
						qualityitem["quality"] = getVideoquality(quality) + getCodec(codecid);
						qualityitem["qualityDetail"] = qualityitem["quality"];
						qualityitem["itag"] = trueitag;
						QualityList.insertLast(qualityitem);
					}
				}
				if (data["dash"]["dolby"]["audio"].isArray()){
					string dolbyquality;
					dolbyquality = formatFloat(data["dash"]["dolby"]["audio"][0]["bandwidth"].asInt() / 1000.0, "", 0, 1) + "K";
					dictionary dolbyqualityitem;
					dolbyqualityitem["url"] = data["dash"]["dolby"]["audio"][0]["baseUrl"].asString();
					dolbyqualityitem["quality"] = "EC-3 " + dolbyquality;
					dolbyqualityitem["qualityDetail"] = dolbyqualityitem["quality"];
					dolbyqualityitem["itag"] = 328;
					QualityList.insertLast(dolbyqualityitem);
				}
				if (data["dash"]["flac"].isObject()){
					string flacquality;
					flacquality = formatFloat(data["dash"]["flac"]["audio"]["bandwidth"].asInt() / 1000.0, "", 0, 1) + "K";
					dictionary flacqualityitem;
					flacqualityitem["url"] = data["dash"]["flac"]["audio"]["baseUrl"].asString();
					flacqualityitem["quality"] = "FLAC" +flacquality;
					flacqualityitem["qualityDetail"] = flacqualityitem["quality"];
					flacqualityitem["itag"] = 258;
					QualityList.insertLast(flacqualityitem);
				}
                JsonValue audios = data["dash"]["audio"];
                if (@QualityList !is null) {
					for (int i = 0; i < audios.size(); i++) {
						string audioquality;
                        audioquality = formatFloat(audios[i]["bandwidth"].asInt() / 1000.0, "", 0, 1) + "K";
						dictionary audioqualityitem;
						int audioid = audios[i]["id"].asInt();
						int audioitag = getAudioItag(audioid);
                        audioqualityitem["url"] = audios[i]["baseUrl"].asString();
						audioqualityitem["quality"] =  "AAC " + audioquality;
						audioqualityitem["qualityDetail"] = audioqualityitem["quality"];
						audioqualityitem["itag"] = audioitag;
						QualityList.insertLast(audioqualityitem);
					}
				}
			} else if (data["durl"].isArray()) {
				url = data["durl"][0]["url"].asString();
				qn = data["quality"].asInt();
				dictionary qualityitem;
				int codecid = data["video_codecid"].asInt();
				JsonValue qualities = data["accept_quality"];
				if (@QualityList !is null) {
					for (uint i = 0; i < qualities.size(); i++) {
						int quality = qualities[i].asInt();
						dictionary qualityitem;
						int quality_codecid;
						if (quality == qn) {
							qualityitem["url"] = url;
							quality_codecid = codecid;
						} else {
							string quality_res;
							if (ispgc) {
								quality_res = apiPost("/pgc/player/web/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + quality + "&fnval=4048&fourk=1");
							} else {
								quality_res = apiPost("/x/player/playurl?avid=" + aid + "&cid=" + cid + "&qn=" + quality + "&fnval=4048&fourk=1");
							}
							JsonValue temp;
							if (reader.parse(quality_res, temp) && temp.isObject()) {
								if (temp["code"].asInt() != 0) {
									continue;
								}
								JsonValue quality_data;
								if (ispgc) {
									quality_data = temp["result"];
								} else {
									quality_data = temp["data"];
								}
								if (quality_data["durl"].isArray()) {
									qualityitem["url"] = quality_data["durl"][0]["url"].asString();
									quality_codecid = quality_data["video_codecid"].asInt();
								}
							}
						}
						int itag = quality * 10 + quality_codecid;
						int trueitag = getTrueItag(itag);
						qualityitem["quality"] = getVideoquality(quality) + getCodec(quality_codecid);
						qualityitem["qualityDetail"] = qualityitem["quality"];
						qualityitem["itag"] = trueitag;
						QualityList.insertLast(qualityitem);
					}
					if (QualityList.length() == 1) {
						dictionary qualityitem2;
						if (data["durl"][0]["backup_url"].isArray() && data["durl"][0]["backup_url"].size() > 0) {
							qualityitem2["url"] = data["durl"][0]["backup_url"][0].asString();
						} else {
							qualityitem2["url"] = url;
						}
						qualityitem2["quality"] = "- " + getVideoquality(qn) + getCodec(codecid) + " 备用";
						qualityitem2["qualityDetail"] = qualityitem2["quality"];
						qualityitem2["itag"] = 1;
						QualityList.insertLast(qualityitem2);
					}
				}
			}
		} else {
			return url;
		}
	}
	if (!title.empty()) {
		log("title", title);
	}
	log("aid", aid);
	log("bvid", bvid);
	log("cid", cid);
	log("url", url);

	return url;
}

array<dictionary> watchlater() {
	array<dictionary> videos;
	string res = apiPost("/x/v2/history/toview");
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				JsonValue data = Root["data"]["list"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							int p = item["page"]["page"].asInt();
							if (p == 1) {
								video["title"] = item["title"].asString();
							} else {
								video["title"] = item["title"].asString() + " | " + item["page"]["part"].asString();
							}
							video["duration"] = item["duration"].asInt() * 1000;
							video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?p=" + p;
							video["thumbnail"] = item["pic"].asString();
							video["author"] = item["owner"]["name"].asString();
							videos.insertLast(video);
						}
					}
				}
			}
		}
	}
	return videos;
}

array<dictionary> History() {
	array<dictionary> videos;
	uint max = 0;
	uint ps = 20;
	string res = apiPost("/x/web-interface/history/cursor?max=" + max + "&ps=" + ps);
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 0) {
				JsonValue data = Root["data"]["list"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						string type = item["history"]["business"].asString();
						// archive live pgc
						if (type == "archive" || type == "live") {
							if (item.isObject()) {
								dictionary video;
								video["thumbnail"] = item["cover"].asString();
								video["author"] = item["author_name"].asString();
								if (type == "live") {
									if (item["live_status"].asInt() != 1) {
										continue;
									}
									video["title"] = "直播 | " + item["title"].asString();
									video["url"] = item["uri"].asString();
								} else if (type == "archive") {
									int p = item["history"]["page"].asInt();
									if (p == 1) {
										video["title"] = item["title"].asString();
									} else {
										video["title"] = item["title"].asString() + " | " + item["history"]["part"].asString();
									}
									video["duration"] = item["duration"].asInt() * 1000;
									video["url"] = "https://www.bilibili.com/video/" + item["history"]["bvid"].asString() + "?p=" + p;
								} else {
									continue;
								}
								videos.insertLast(video);
							}
						}
					}
				}
			}
		}
	}
	return videos;
}

string parse(string url, string key, string defaultValue="") {
	string value = HostRegExpParse(url, "\\?" + key + "=([^&]+)");
	if (!value.empty()) {
		return value;
	}
	value = HostRegExpParse(url, "&" + key + "=([^&]+)");
	if (!value.empty()) {
		return value;
	}

	value = defaultValue;
	return value;
}

string parseBVId(string url) {
	return HostRegExpParse(url, "(BV[a-zA-Z0-9]+)");
}

string parseAVId(string url) {
	return HostRegExpParse(url, "av([0-9]+)");
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

array<dictionary> Channel(string path) {
	array<dictionary> videos;
	int ps = 100;
	int pn = 1;
	string uid = HostRegExpParse(path, "/([0-9]+)");
	string sid = parse(path, "sid");
	string baseurl;
	bool isCollection = path.find("collectiondetail") >= 0;
	if (isCollection) {
		baseurl = "/x/polymer/space/seasons_archives_list?mid=" + uid + "&season_id=" + sid + "&sort_reverse=" + parse(path, "sort_reverse", "false") + "&page_size=" + ps;
	} else {
		baseurl = "/x/series/archives?mid=" + uid + "&series_id=" + sid + "&sort=desc" + "&ps=" + ps;
	}
	while (true){
		string url;
		if (isCollection) {
			url = baseurl + "&page_num=" + pn;
		} else {
			url = baseurl + "&pn=" + pn;
		}
		string res = apiPost(url);
		if (!res.empty()) {
			JsonReader Reader;
			JsonValue Root;
			if (Reader.parse(res, Root) && Root.isObject()) {
				if (Root["code"].asInt() == 0) {
					JsonValue data = Root["data"]["archives"];
					if (data.isArray()) {
						for (int i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary video;
								video["title"] = item["title"].asString();
								video["duration"] = item["length"].asInt() * 1000;
								video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
								video["thumbnail"] = item["pic"].asString();
								videos.insertLast(video);
							}
						}
					}
					JsonValue page = Root["data"]["page"];
					if (isCollection) {
						if (page["page_num"].asInt() * page["page_size"].asInt() >= page["total"].asInt()) {
							break;
						}
					} else {
						if (page["num"].asInt() * page["size"].asInt() >= page["total"].asInt()) {
							break;
						}
					}
					pn += 1;
				} else {
					return videos;
				}
			}
		} else {
			return videos;
		}
	}

	return videos;
}

array<dictionary> spaceVideo(string path) {
	array<dictionary> videos;
	int ps = 50;
	int page = parseInt(parse(path, "pn", "1"));
	int pn = page;
	string baseurl = "/x/space/wbi/arc/search?";
	string params1;
	string params2;
	params1 += "keyword=" + parse(path, "keyword");
	params1 += "&mid=" + HostRegExpParse(path, "/([0-9]+)");
	params1 += "&order=" + parse(path, "order", "pubdate");

	params2 += "&ps=" + ps;
	params2 += "&tid=" + parse(path, "tid", "0");
	while (true) {
		if (pn - page >= 10) {
			break;
		}
		string params = params1 + "&pn=" + pn + params2;
		string w_rid = encWbi(params);
		params += "&w_rid=" + w_rid;

		string url = baseurl + params;
		string res = apiPost(url);
		if (!res.empty()) {
			JsonReader Reader;
			JsonValue Root;
			if (Reader.parse(res, Root) && Root.isObject()) {
				if (Root["code"].asInt() == 0) {
					JsonValue data = Root["data"]["list"]["vlist"];
					if (data.isArray()) {
						for (int i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary video;
								video["title"] = item["title"].asString();
								video["duration"] = parseTime(item["length"].asString());
								video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
								video["thumbnail"] = item["pic"].asString();
								video["author"] = item["author"].asString();
								videos.insertLast(video);
							}
						}
					}
					JsonValue page = Root["data"]["page"];
					if (page["pn"].asInt() * page["ps"].asInt() >= page["count"].asInt()) {
						break;
					}
					pn += 1;
				} else {
					return videos;
				}
			}
		} else {
			return videos;
		}
	}
	return videos;
}

array<dictionary> spaceAudio(string path) {
	array<dictionary> audios;
	int ps = 50;
	int pn = 1;
	string baseurl = "/audio/music-service/web/song/upper?";
	baseurl += "uid=" + HostRegExpParse(path, "/([0-9]+)");
	baseurl += "&ps=" + ps;
	baseurl += "&order=" + parse(path, "order", "1");
	while (true) {
		string url = baseurl + "&pn=" + pn;
		string res = apiPost(url);
		if (!res.empty()) {
			JsonReader Reader;
			JsonValue Root;
			if (Reader.parse(res, Root) && Root.isObject()) {
				if (Root["code"].asInt() == 0) {
					JsonValue data = Root["data"]["data"];
					if (data.isArray()) {
						for (int i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary audio;
								audio["title"] = item["title"].asString();
								audio["duration"] = item["duration"].asInt() * 1000;
								audio["url"] = "https://www.bilibili.com/audio/au" + item["id"].asString();
								audio["thumbnail"] = item["cover"].asString();
								audios.insertLast(audio);
							}
						}
					}
					if (Root["data"]["curPage"].asInt() >= Root["data"]["pageCount"].asInt()) {
						break;
					}
					pn += 1;
				} else {
					return audios;
				}
			}
		} else {
			return audios;
		}
	}
	return audios;
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
			mid = "" + ConfigData.uid;
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
	int pn = 1;
	int ps = 20;
	string baseurl;
	string url;
	string ftype = parse(path, "ftype");
	// 订阅和收藏
	if (ftype == "collect") {
		baseurl = "/x/space/fav/season/list?season_id=" + fid;
	} else {
		baseurl = "/x/v3/fav/resource/list?media_id=" + fid + "&ps=" + ps;
		baseurl += "&keyword=" + parse(path, "keyword");
		baseurl += "&order=" + parse(path, "order", "mtime");
		// url += "&type=" + parse(path, "type", "0");
		baseurl += "&tid=" + parse(path, "tid", "0");
	}
	while (true) {
		if (ftype == "collect") {
			url = baseurl;
		} else {
			url = baseurl + "&pn=" + pn;
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
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							video["title"] = item["title"].asString();
							video["duration"] = item["duration"].asInt() * 1000;
							video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
							video["thumbnail"] = item["cover"].asString();
							video["author"] = item["upper"]["name"].asString();
							videos.insertLast(video);
						}
					}
				}
				if (ftype == "collect") {
					return videos;
				}
				int count = Root["data"]["info"]["media_count"].asInt();
				if (pn * ps >= count) {
					break;
				}
				pn += 1;
			} else {
				return videos;
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
				for (int i = 0; i < list.size(); i++) {
					JsonValue item = list[i];
					// 未开播
					if (item["live_status"].asInt() == 0) {
						return videos;
					}
					dictionary video;
					video["title"] = item["title"].asString();
					video["url"] = "https://live.bilibili.com/" + item["roomid"].asInt();
					video["thumbnail"] = item["face"].asString();
					video["author"] = item["uname"].asString();
					videos.insertLast(video);
				}
				if (page < Root["data"]["totalPage"].asUInt()) {
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

array<dictionary> liveCategory(uint page,string cateid,string parentAreaId) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string url = "https://api.live.bilibili.com/xlive/web-interface/v1/second/getList?platform=web&parent_area_id="+parentAreaId+"&area_id="+cateid+"&page=" + page;
	string res = post(url);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() == 0) {
			JsonValue list = Root["data"]["list"];
			if (list.isArray()) {
				for (int i = 0; i < list.size(); i++) {
					JsonValue item = list[i];
					dictionary video;
					video["title"] = item["title"].asString();
					video["url"] = "https://live.bilibili.com/" + item["roomid"].asInt();
					video["thumbnail"] = item["face"].asString();
					video["author"] = item["uname"].asString();
					videos.insertLast(video);
				}
				if ((page - 1) * list.size() < 200) {
					array<dictionary> videos2 = liveCategory(page+1,cateid,parentAreaId);
					for (uint i = 0; i < videos2.size(); i++) {
						videos.insertLast(videos2[i]);
					}
				}
			}
		}
	}
	return videos;
}

array<dictionary> PopularHistory() {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string res = apiPost("/x/web-interface/popular/precious?page_size=100&page=1");
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["list"];
		if (list.isArray()) {
			for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				video["title"] = item["title"].asString();
				video["duration"] = item["duration"].asInt() * 1000;
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
				video["thumbnail"] = item["pic"].asString();
				video["author"] = item["owner"]["name"].asString();
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

array<dictionary> PopularWeekly(string path) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string num = parse(path, "num");
	if (num.empty()) {
		string res = apiPost("/x/web-interface/popular/series/list");
		if (res.empty()) {
			return videos;
		}
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() != 0) {
				return videos;
			}
			JsonValue list = Root["data"]["list"];
			if (list.isArray()) {
				num = "" + list[0]["number"].asInt();
			}
		}
	}
	string res = apiPost("/x/web-interface/popular/series/one?number=" + num);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["list"];
		if (list.isArray()) {
			for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				video["title"] = item["title"].asString();
				video["duration"] = item["duration"].asInt() * 1000;
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
				video["thumbnail"] = item["pic"].asString();
				video["author"] = item["owner"]["name"].asString();
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

array<dictionary> Ranking(string path) {
	array<dictionary> videos;

	array<string> names = { "全站", "国创相关", "动画", "音乐", "舞蹈", "游戏", "知识", "科技", "运动", "汽车", "生活", "美食", "动物圈", "鬼畜", "时尚", "娱乐", "影视" };
	array<string> urls = { "www.bilibili.com/v/popular/rank/all", "www.bilibili.com/v/popular/rank/guochuang", "www.bilibili.com/v/popular/rank/douga", "www.bilibili.com/v/popular/rank/music", "www.bilibili.com/v/popular/rank/dance", "www.bilibili.com/v/popular/rank/game", "www.bilibili.com/v/popular/rank/knowledge", "www.bilibili.com/v/popular/rank/tec", "www.bilibili.com/v/popular/rank/spor", "www.bilibili.com/v/popular/rank/car", "www.bilibili.com/v/popular/rank/life", "www.bilibili.com/v/popular/rank/food", "www.bilibili.com/v/popular/rank/animal", "www.bilibili.com/v/popular/rank/kichiku", "www.bilibili.com/v/popular/rank/fashion", "www.bilibili.com/v/popular/rank/en", "www.bilibili.com/v/popular/rank/cinephile" };
	array<uint> ids = { 0, 168, 1, 3, 129, 4, 36, 188, 234, 223, 160, 211, 217, 119, 155, 5, 181 };
	int pos = -1;
	for (uint i = 0; i < urls.size(); i++) {
		if (path.find(urls[i]) >= 0) {
			pos = i;
			break;
		}
	}
	if (pos < 0) {
		return videos;
	}

	JsonReader Reader;
	JsonValue Root;

	string res = apiPost("/x/web-interface/ranking/v2?rid=" + ids[pos]);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["list"];
		if (list.isArray()) {
			for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				video["title"] = item["title"].asString();
				video["duration"] = item["duration"].asInt() * 1000;
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
				video["thumbnail"] = item["pic"].asString();
				video["author"] = item["owner"]["name"].asString();
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

array<dictionary> Dynamic(uint tid) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string res = apiPost("/x/web-interface/dynamic/region?pn=1&ps=50&rid=" + tid);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list = Root["data"]["archives"];
		if (list.isArray()) {
			for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				video["title"] = item["title"].asString();
				video["duration"] = item["duration"].asInt() * 1000;
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
				video["thumbnail"] = item["pic"].asString();
				video["author"] = item["owner"]["name"].asString();
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
			for (int i = 0; i < episodes.size(); i++) {
				JsonValue item = episodes[i];
				dictionary video;
				if (item["badge"].asString().empty()) {
					video["title"] = item["share_copy"].asString();
				} else {
					video["title"] = "【" + item["badge"].asString() + "】" + item["share_copy"].asString();
				}
				video["duration"] = item["duration"].asInt();
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString() + "?cid=" + item["cid"].asString();
				video["thumbnail"] = item["cover"].asString();
				videos.insertLast(video);
			}
		}
	}
	return videos;
}

array<dictionary> AudioList(string path) {
	array<dictionary> audios;
	JsonReader Reader;
	JsonValue Root;
	string id = HostRegExpParse(path, "www.bilibili.com/audio/am([0-9]+)");
	if (id.empty()) {
		return audios;
	}
	string url = "https://www.bilibili.com/audio/music-service-c/web/song/of-menu?pn=1&ps=100&sid=" + id;
	string res = post(url);
	res = HostDecompress(res);
	if (res.empty()) {
		return audios;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return audios;
		}
		JsonValue data = Root["data"]["data"];
		if (data.isArray()) {
			for (int i = 0; i < data.size(); i++) {
				JsonValue item = data[i];
				dictionary audio;
				audio["title"] = item["title"].asString();
				audio["duration"] = item["duration"].asInt() * 1000;
				audio["url"] = "https://www.bilibili.com/audio/au" + item["statistic"]["sid"].asInt();
				audio["thumbnail"] = item["cover"].asString();
				if (item["author"].isString()) {
					audio["author"] = item["author"].asString();
				}
				audios.insertLast(audio);
			}
		}
	}
	return audios;
}

array<dictionary> Search(string path) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string kw;
	if (path.find("?WithCaption") >= 0) {
		path.replace("?WithCaption", "");
		kw = HostUrlEncode(parse(path, "keyword"));
	} else {
		kw = parse(path, "keyword");
	}
	if (kw.empty()) {
		return videos;
	}
	string type = HostRegExpParse(path, "search.bilibili.com/([a-zA-Z0-9]+)");
	string url;
	if (type == "all") {
		url = "/x/web-interface/search/all/v2?keyword=" + kw;
	} else if (type == "video") {
		url = "/x/web-interface/search/type?search_type=video&keyword=" + kw;
	} else {
		return videos;
	}
	string res = apiPost(url);
	if (res.empty()) {
		return videos;
	}
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return videos;
		}
		JsonValue list;
		if (type == "all") {
			for (int i = 0; i < Root["data"]["result"].size(); i++) {
				if (Root["data"]["result"][i]["result_type"].asString() == "video") {
					list = Root["data"]["result"][i]["data"];
					break;
				}
			}
		} else if (type == "video") {
			list = Root["data"]["result"];
		} else {
			return videos;
		}
		for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				dictionary video;
				string title = item["title"].asString();
				title.replace("<em class=\"keyword\">", '');
				title.replace("</em>", '');
				video["title"] = title;
				video["content"] = title;
				video["duration"] = parseTime(item["duration"].asString());
				video["url"] = "https://www.bilibili.com/video/" + item["bvid"].asString();
				video["thumbnail"] = "https:" + item["pic"].asString();
				video["author"] = item["author"].asString();
				videos.insertLast(video);
		}
	}
	return videos;
}

array<dictionary> webDynamic(string path) {
	array<dictionary> videos;
	JsonReader Reader;
	JsonValue Root;
	string type = parse(path, "tab");
	if (type != "video") {
		type = "all";
	}
	int nums = 2;
	string offset;
	string baseurl ="/x/polymer/web-dynamic/v1/feed/all?timezone_offset=-480&type=" + type;
	for (int i = 1; i <= nums; i++) {
		string url = baseurl + "&page=" + i;
		if (!offset.empty()) {
			url += "&offset=" + offset;
		}
		string res = apiPost(url);
		if (res.empty()) {
			return videos;
		}
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() != 0) {
				return videos;
			}
			JsonValue list = Root["data"]["items"];
			if (list.isArray()) {
				offset = Root["data"]["offset"].asString();
				for (int j = 0; j < list.size(); j++) {
					JsonValue dynamic = list[j]["modules"]["module_dynamic"];
					if (dynamic.isObject()) {
						JsonValue major = dynamic["major"];
						if (!major.isObject()) {
							continue;
						}
						string author = list[j]["modules"]["module_author"]["name"].asString();
						JsonValue archive = major["archive"];
						if (archive.isObject()) {
							if (archive["bvid"].isString() && !archive["bvid"].asString().empty()) {
								string bvid = archive["bvid"].asString();
								dictionary video;
								video["title"] = "视频 | " + archive["title"].asString();
								video["duration"] = parseTime(archive["duration_text"].asString());
								video["url"] = "https://www.bilibili.com/video/" + bvid;
								video["thumbnail"] = archive["cover"].asString();
								video["author"] = author;
								videos.insertLast(video);
							}
							continue;
						}
						JsonValue live_rcmd = major["live_rcmd"];
						if (live_rcmd.isObject()) {
							string content_str = live_rcmd["content"].asString();
							JsonValue content;
							if (Reader.parse(content_str, content) && content.isObject()) {
								if (content["live_play_info"]["live_status"].asInt() == 1) {
									dictionary live;
									live["title"] = "直播 | " + content["live_play_info"]["title"].asString();
									live["url"] = "https://live.bilibili.com/" + content["live_play_info"]["room_id"].asString();
									live["thumbnail"] = content["live_play_info"]["cover"].asString();
									live["author"] = author;
									videos.insertLast(live);
								}
							}
							continue;
						}
					}
				}
				if (!Root["data"]["has_more"].asBool()) {
					break;
				}
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
	string url ="/x/web-interface/index/top/feed/rcmd?y_num=3&fresh_type=4&feed_version=V8&fresh_idx_1h="+page+"&fetch_row="+(3*page+1)+"&fresh_idx="+page+"&brush="+page+"&homepage_ver=1&ps=12&last_y_num=4&outside_trigger=";
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
			for (int i = 0; i < list.size(); i++) {
				JsonValue item = list[i];
				if (item["bvid"].asString().empty()) {
					continue;
				}
				dictionary video;
				video["thumbnail"] = item["pic"].asString();
				video["author"] = item["owner"]["name"].asString();
				if (item["uri"].asString().find("live.bilibili.com") >= 0) {
					video["title"] = "直播 | " + item["title"].asString();
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

int getTrueItag(int itag) {
	array<int> itags = {1282,1283,1272,1273,1262,1263,1207,1212,1213,1167,1172,1173,1127,1132,1133,807,812,813,647,652,653,327,332,333,167,172,173,67,72,73};
	array<int> tis = {102,571,101,702,266,701,138,272,401,299,303,699,264,271,400,137,248,399,136,247,398,135,244,397,134,243,396,133,242,395};
	int idx = itags.find(itag);
	if (idx >= 0) {
		return tis[idx];
	}
	return itag;
}

int getAudioItag(int id) {
	array<int> ids = {30280, 30232, 30216};
	array<int> itags = {327, 256, 139};
	int idx = ids.find(id);
	if (idx >= 0) {
		return itags[idx];
	}
	return id;
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

string getCodec(int codecid) {
	array<int> codecids = {7, 12, 13};
	array<string> codec = {" AVC", " HEVC", " AV1"};
	int idx = codecids.find(codecid);
	if (idx >= 0) {
		return codec[idx];
	}
	return "未知";
}

string Audio(const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string id = HostRegExpParse(path, "/audio/au([0-9]+)");
	JsonReader Reader;
	JsonValue Root;
	string url;
	string res;

	res = post("https://www.bilibili.com/audio/music-service-c/web/song/info?sid=" + id);
	res = HostDecompress(res);
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return "";
		}
		JsonValue data = Root["data"];
		MetaData["title"] = data["title"].asString();
		MetaData["thumbnail"] = data["cover"].asString();
		if (data["author"].isString()) {
			MetaData["author"] = data["author"].asString();
		}
	}

	status = 3;
	res = post("https://www.bilibili.com/audio/music-service-c/web/url?privilege=2&quality=2&sid=" + id);
	res = HostDecompress(res);
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return "";
		}
		JsonValue data = Root["data"]["cdns"];
		if (data.isArray()) {
			return data[0].asString();
		}
	}
	return url;
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
		string author = Root["data"]["anchor_info"]["base_info"]["uname"].asString();
		MetaData["title"] = data["title"].asString();

		string desc = data["description"].asString();
		if (desc.empty()) {
			desc = data["title"].asString();
		}
		MetaData["author"] = author;
		MetaData["content"] = data["area_name"].asString() + " | " + desc;
		MetaData["webUrl"] = makeWebUrl(path);
		MetaData["thumbnail"] = data["cover"].asString();
		room_id = data["room_id"].asInt();
	}
	status = 3;
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
			if (@QualityList !is null) {
				for (int i = 0; i < qualities.size(); i++) {
					int quality = qualities[i]["qn"].asInt();
					dictionary qualityitem;
					dictionary qualityitem2;
					string backup_url;
					if (quality == qn) {
						qualityitem["url"] = url;
						if (data.size() > 1) {
							qualityitem2["url"] = data[1]["url"].asString();
						}
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
								if (qyality_data.size() > 1) {
									qualityitem2["url"] = qyality_data[1]["url"].asString();
								}
							}
						}
					}
					int itag = getItag(quality);
					qualityitem["quality"] = qualities[i]["desc"].asString();
					qualityitem["qualityDetail"] = qualityitem["quality"];
					qualityitem["itag"] = itag;
					QualityList.insertLast(qualityitem);

					qualityitem2["quality"] =  "- " + qualities[i]["desc"].asString() + " 备份";
					qualityitem2["qualityDetail"] = qualityitem2["quality"];
					qualityitem2["itag"] = itag + 20;
					QualityList.insertLast(qualityitem2);
				}
			}
		}
	}
	return url;
}

bool PlayitemCheck(const string &in path) {
	status = 0;
	if (path.find("bilibili.com") < 0) {
		return false;
	}

	if (path.find("/video/BV") >= 0) {
		return true;
	}

	if (path.find("live.bilibili.com") >= 0) {
		return true;
	}
	if (path.find("www.bilibili.com/audio/au") >= 0) {
		return true;
	}

	return false;
}

bool PlaylistCheck(const string &in path) {
	status = 0;
	if (path.find("bilibili.com") < 0) {
		return false;
	}
	if (!parseBVId(path).empty() || !parseAVId(path).empty()) {
		return true;
	}
	if (path.find("search.bilibili.com") >= 0) {
		return true;
	}
	if (path.find("/watchlater") >= 0) {
		return true;
	}
	if (path.find("/account/history") >= 0) {
		return true;
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
		else if (path.find("/channel/collectiondetail") >= 0 || path.find("/channel/seriesdetail") >= 0) {
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
	if(path.find("live.bilibili.com") >= 0){
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
	if (path.find("www.bilibili.com/v/popular/rank") >= 0) {
		return true;
	}
	if (path.find("www.bilibili.com/v/popular/history") >= 0) {
		return true;
	}
	if (path.find("www.bilibili.com/v/popular/weekly") >= 0) {
		return true;
	}
	if (gettid(path) > 0) {
		return true;
	}
	if (path.find("www.bilibili.com/audio/am") >= 0) {
		return true;
	}
	if (path.find("t.bilibili.com") >= 0) {
		return true;
	}

	return false;
}

array<dictionary> PlaylistParse(const string &in path) {
	log("Playlist path", path);
	status = 1;
	array<dictionary> result;

	string bvid = parseBVId(path);
	if (!bvid.empty()) {
		return VideoPages(bvid);
	}
	string avid = parseAVId(path);
	if (!avid.empty()) {
		return VideoPages(avid);
	}
	if (path.find("/watchlater") >= 0) {
		return watchlater();
	}
	if (path.find("/account/history") >= 0) {
		return History();
	}
	if (path.find("search.bilibili.com") >= 0) {
		return Search(path);
	}
	if (path.find("space.bilibili.com") >= 0) {
		if (path.find("/video") >= 0) {
			return spaceVideo(path);
		}
		else if (path.find("/audio") >= 0) {
			return spaceAudio(path);
		}
		else if (path.find("/favlist") >= 0) {
			return FavList(path);
		}
		else if (path.find("/channel/collectiondetail") >= 0 || path.find("/channel/seriesdetail") >= 0) {
			return Channel(path);
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
	if(path.find("live.bilibili.com") >= 0) {
		if(path.find("areaId") >= 0){
			return liveCategory(2,HostRegExpParse(path, "areaId=([0-9]+)"), HostRegExpParse(path, "parentAreaId=([0-9]+)"));
		}
		if(path.find("lol") >= 0){
			return liveCategory(2,"86","2");
		}
		if(path.find("hpjy") >= 0){
			return liveCategory(2,"256","3");
		}
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
	if (path.find("www.bilibili.com/v/popular/rank") >= 0) {
		return Ranking(path);
	}
	if (path.find("www.bilibili.com/v/popular/history") >= 0) {
		return PopularHistory();
	}
	if (path.find("www.bilibili.com/v/popular/weekly") >= 0) {
		return PopularWeekly(path);
	}
	if (path.find("www.bilibili.com/audio/am") >= 0) {
		return AudioList(path);
	}
	uint tid = gettid(path);
	if (tid > 0) {
		return Dynamic(tid);
	}
	if (path.find("t.bilibili.com") >= 0) {
		return webDynamic(path);
	}

	return result;
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	log("Playitem path", path);
	status = 2;
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
	if (path.find("www.bilibili.com/audio/au") >= 0) {
		return Audio(path, MetaData, QualityList);
	}

	return path;
}

