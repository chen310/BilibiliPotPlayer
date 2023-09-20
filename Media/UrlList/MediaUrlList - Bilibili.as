/*
	media url search by bilibili
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
// array<dictionary> GetCategorys()						-> get category list
// string GetSorts(string Category, string Extra, string PathToken, string Query)									-> get sort option
// array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)	-> get url list for Category

string GetTitle()
{
	return "Bilibili";
}

string GetVersion()
{
	return "1.0";
}

string GetDesc()
{
	return "https://www.bilibili.com";
}

string post(string url, string data="") {
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	string Headers = "Referer: https://www.bilibili.com\r\n";
	return HostUrlGetStringWithAPI(url, UserAgent, Headers, data, true);
}

array<dictionary> Ranking() {
	return {
		{ { "title", "全站" }, { "url", "https://www.bilibili.com/v/popular/rank/all" } },
		{ { "title", "国创相关" }, { "url", "https://www.bilibili.com/v/popular/rank/guochuang" } },
		{ { "title", "动画" }, { "url", "https://www.bilibili.com/v/popular/rank/douga" } },
		{ { "title", "音乐" }, { "url", "https://www.bilibili.com/v/popular/rank/music" } },
		{ { "title", "舞蹈" }, { "url", "https://www.bilibili.com/v/popular/rank/dance" } },
		{ { "title", "游戏" }, { "url", "https://www.bilibili.com/v/popular/rank/game" } },
		{ { "title", "知识" }, { "url", "https://www.bilibili.com/v/popular/rank/knowledge" } },
		{ { "title", "科技" }, { "url", "https://www.bilibili.com/v/popular/rank/tec" } },
		{ { "title", "运动" }, { "url", "https://www.bilibili.com/v/popular/rank/spor" } },
		{ { "title", "汽车" }, { "url", "https://www.bilibili.com/v/popular/rank/car" } },
		{ { "title", "生活" }, { "url", "https://www.bilibili.com/v/popular/rank/life" } },
		{ { "title", "美食" }, { "url", "https://www.bilibili.com/v/popular/rank/food" } },
		{ { "title", "动物圈" }, { "url", "https://www.bilibili.com/v/popular/rank/animal" } },
		{ { "title", "鬼畜" }, { "url", "https://www.bilibili.com/v/popular/rank/kichiku" } },
		{ { "title", "时尚" }, { "url", "https://www.bilibili.com/v/popular/rank/fashion" } },
		{ { "title", "娱乐" }, { "url", "https://www.bilibili.com/v/popular/rank/en" } },
		{ { "title", "影视" }, { "url", "https://www.bilibili.com/v/popular/rank/cinephile" } },
	};
}

array<dictionary> Dynamic() {
	return {
		{ { "title", "番剧" }, { "url", "https://www.bilibili.com/anime/" } },
		{ { "title", "- 连载动画" }, { "url", "https://www.bilibili.com/v/anime/serial/" } },
		{ { "title", "- 完结动画" }, { "url", "https://www.bilibili.com/v/anime/finish" } },
		{ { "title", "- 资讯" }, { "url", "https://www.bilibili.com/v/anime/information/" } },
		{ { "title", "- 官方延伸" }, { "url", "https://www.bilibili.com/v/anime/offical/" } },
		{ { "title", "电影" }, { "url", "https://www.bilibili.com/movie/" } },
		{ { "title", "国创" }, { "url", "https://www.bilibili.com/guochuang/" } },
		{ { "title", "- 国产动画" }, { "url", "https://www.bilibili.com/v/guochuang/chinese/" } },
		{ { "title", "- 国产原创相关" }, { "url", "https://www.bilibili.com/v/guochuang/original/" } },
		{ { "title", "- 布袋戏" }, { "url", "https://www.bilibili.com/v/guochuang/puppetry/" } },
		{ { "title", "- 动态漫·广播剧" }, { "url", "https://www.bilibili.com/v/guochuang/motioncomic/" } },
		{ { "title", "- 资讯" }, { "url", "https://www.bilibili.com/v/guochuang/information/" } },
		{ { "title", "电视剧" }, { "url", "https://www.bilibili.com/tv/" } },
		{ { "title", "纪录片" }, { "url", "https://www.bilibili.com/documentary/" } },
		{ { "title", "动画" }, { "url", "https://www.bilibili.com/v/douga/" } },
		{ { "title", "- MAD·AMV" }, { "url", "https://www.bilibili.com/v/douga/mad/" } },
		{ { "title", "- MMD·3D" }, { "url", "https://www.bilibili.com/v/douga/mmd/" } },
		{ { "title", "- 短片·手书·配音" }, { "url", "https://www.bilibili.com/v/douga/voice/" } },
		{ { "title", "- 手办·模玩" }, { "url", "https://www.bilibili.com/v/douga/garage_kit/" } },
		{ { "title", "- 特摄" }, { "url", "https://www.bilibili.com/v/douga/tokusatsu/" } },
		{ { "title", "- 动漫杂谈" }, { "url", "https://www.bilibili.com/v/douga/acgntalks/" } },
		{ { "title", "- 综合" }, { "url", "https://www.bilibili.com/v/douga/other/" } },
		{ { "title", "游戏" }, { "url", "https://www.bilibili.com/v/game/" } },
		{ { "title", "- 单机游戏" }, { "url", "https://www.bilibili.com/v/game/stand_alone" } },
		{ { "title", "- 电子竞技" }, { "url", "https://www.bilibili.com/v/game/esports" } },
		{ { "title", "- 手机游戏" }, { "url", "https://www.bilibili.com/v/game/mobile" } },
		{ { "title", "- 网络游戏" }, { "url", "https://www.bilibili.com/v/game/online" } },
		{ { "title", "- 桌游棋牌" }, { "url", "https://www.bilibili.com/v/game/board" } },
		{ { "title", "- GMV" }, { "url", "https://www.bilibili.com/v/game/gmv" } },
		{ { "title", "- 音游" }, { "url", "https://www.bilibili.com/v/game/music" } },
		{ { "title", "- Mugen" }, { "url", "https://www.bilibili.com/v/game/mugen" } },
		{ { "title", "鬼畜" }, { "url", "https://www.bilibili.com/v/kichiku/" } },
		{ { "title", "- 鬼畜调教" }, { "url", "https://www.bilibili.com/v/kichiku/guide" } },
		{ { "title", "- 音MAD" }, { "url", "https://www.bilibili.com/v/kichiku/mad" } },
		{ { "title", "- 人力VOCALOID" }, { "url", "https://www.bilibili.com/v/kichiku/manual_vocaloid" } },
		{ { "title", "- 鬼畜剧场" }, { "url", "https://www.bilibili.com/v/kichiku/theatre" } },
		{ { "title", "- 教程演示" }, { "url", "https://www.bilibili.com/v/kichiku/course" } },
		{ { "title", "音乐" }, { "url", "https://www.bilibili.com/v/music" } },
		{ { "title", "- 原创音乐" }, { "url", "https://www.bilibili.com/v/music/original" } },
		{ { "title", "- 翻唱" }, { "url", "https://www.bilibili.com/v/music/cover" } },
		{ { "title", "- 演奏" }, { "url", "https://www.bilibili.com/v/music/perform" } },
		{ { "title", "- VOCALOID·UTAU" }, { "url", "https://www.bilibili.com/v/music/vocaloid" } },
		{ { "title", "- 音乐现场" }, { "url", "https://www.bilibili.com/v/music/live" } },
		{ { "title", "- MV" }, { "url", "https://www.bilibili.com/v/music/mv" } },
		{ { "title", "- 乐评盘点" }, { "url", "https://www.bilibili.com/v/music/commentary" } },
		{ { "title", "- 音乐教学" }, { "url", "https://www.bilibili.com/v/music/tutorial" } },
		{ { "title", "- 音乐综合" }, { "url", "https://www.bilibili.com/v/music/other" } },
		{ { "title", "舞蹈" }, { "url", "https://www.bilibili.com/v/dance/" } },
		{ { "title", "- 宅舞" }, { "url", "https://www.bilibili.com/v/dance/otaku/" } },
		{ { "title", "- 街舞" }, { "url", "https://www.bilibili.com/v/dance/hiphop/" } },
		{ { "title", "- 明星舞蹈" }, { "url", "https://www.bilibili.com/v/dance/star/" } },
		{ { "title", "- 中国舞" }, { "url", "https://www.bilibili.com/v/dance/china/" } },
		{ { "title", "- 舞蹈综合" }, { "url", "https://www.bilibili.com/v/dance/three_d/" } },
		{ { "title", "- 舞蹈教程" }, { "url", "https://www.bilibili.com/v/dance/demo/" } },
		{ { "title", "影视" }, { "url", "https://www.bilibili.com/v/cinephile" } },
		{ { "title", "- 影视杂谈" }, { "url", "https://www.bilibili.com/v/cinephile/cinecism" } },
		{ { "title", "- 影视剪辑" }, { "url", "https://www.bilibili.com/v/cinephile/montage" } },
		{ { "title", "- 小剧场" }, { "url", "https://www.bilibili.com/v/cinephile/shortfilm" } },
		{ { "title", "- 预告·资讯" }, { "url", "https://www.bilibili.com/v/cinephile/trailer_info" } },
		{ { "title", "娱乐" }, { "url", "https://www.bilibili.com/v/ent/" } },
		{ { "title", "- 综艺" }, { "url", "https://www.bilibili.com/v/ent/variety" } },
		{ { "title", "- 娱乐杂谈" }, { "url", "https://www.bilibili.com/v/ent/talker" } },
		{ { "title", "- 粉丝创作" }, { "url", "https://www.bilibili.com/v/ent/fans" } },
		{ { "title", "-  明星综合" }, { "url", "https://www.bilibili.com/v/ent/celebrity" } },
		{ { "title", "知识" }, { "url", "https://www.bilibili.com/v/knowledge/" } },
		{ { "title", "- 科学科普" }, { "url", "https://www.bilibili.com/v/knowledge/science" } },
		{ { "title", "- 社科·法律·心理" }, { "url", "https://www.bilibili.com/v/knowledge/social_science" } },
		{ { "title", "- 人文历史" }, { "url", "https://www.bilibili.com/v/knowledge/humanity_history" } },
		{ { "title", "- 财经商业" }, { "url", "https://www.bilibili.com/v/knowledge/business" } },
		{ { "title", "- 校园学习" }, { "url", "https://www.bilibili.com/v/knowledge/campus" } },
		{ { "title", "- 职业职场" }, { "url", "https://www.bilibili.com/v/knowledge/career" } },
		{ { "title", "- 设计·创意" }, { "url", "https://www.bilibili.com/v/knowledge/design" } },
		{ { "title", "- 野生技能协会" }, { "url", "https://www.bilibili.com/v/knowledge/skill" } },
		{ { "title", "科技" }, { "url", "https://www.bilibili.com/v/tech/" } },
		{ { "title", "- 数 码" }, { "url", "https://www.bilibili.com/v/tech/digital" } },
		{ { "title", "- 软件应用" }, { "url", "https://www.bilibili.com/v/tech/application" } },
		{ { "title", "- 计算机技术" }, { "url", "https://www.bilibili.com/v/tech/computer_tech" } },
		{ { "title", "- 科工机械" }, { "url", "https://www.bilibili.com/v/tech/industry" } },
		{ { "title", "资讯" }, { "url", "https://www.bilibili.com/v/information/" } },
		{ { "title", "- 热点" }, { "url", "https://www.bilibili.com/v/information/hotspot" } },
		{ { "title", "- 环球" }, { "url", "https://www.bilibili.com/v/information/global" } },
		{ { "title", "- 社会" }, { "url", "https://www.bilibili.com/v/information/social" } },
		{ { "title", "- 综合" }, { "url", "https://www.bilibili.com/v/information/multiple" } },
		{ { "title", "美食" }, { "url", "https://www.bilibili.com/v/food" } },
		{ { "title", "- 美食制作" }, { "url", "https://www.bilibili.com/v/food/make" } },
		{ { "title", "- 美食侦探" }, { "url", "https://www.bilibili.com/v/food/detective" } },
		{ { "title", "- 美食测评" }, { "url", "https://www.bilibili.com/v/food/measurement" } },
		{ { "title", "- 田园美食" }, { "url", "https://www.bilibili.com/v/food/rural" } },
		{ { "title", "- 美食记录" }, { "url", "https://www.bilibili.com/v/food/record" } },
		{ { "title", "生活" }, { "url", "https://www.bilibili.com/v/life" } },
		{ { "title", "- 搞笑" }, { "url", "https://www.bilibili.com/v/life/funny" } },
		{ { "title", "- 亲子" }, { "url", "https://www.bilibili.com/v/life/parenting" } },
		{ { "title", "- 出行" }, { "url", "https://www.bilibili.com/v/life/travel" } },
		{ { "title", "- 三农" }, { "url", "https://www.bilibili.com/v/life/rurallife" } },
		{ { "title", "- 家居房产" }, { "url", "https://www.bilibili.com/v/life/home" } },
		{ { "title", "- 手工" }, { "url", "https://www.bilibili.com/v/life/handmake" } },
		{ { "title", "- 绘画" }, { "url", "https://www.bilibili.com/v/life/painting" } },
		{ { "title", "- 日常" }, { "url", "https://www.bilibili.com/v/life/daily" } },
		{ { "title", "汽车" }, { "url", "https://www.bilibili.com/v/car" } },
		{ { "title", "- 赛车" }, { "url", "https://www.bilibili.com/v/car/racing" } },
		{ { "title", "- 改装玩车" }, { "url", "https://www.bilibili.com/v/car/modifiedvehicle" } },
		{ { "title", "- 新能源车" }, { "url", "https://www.bilibili.com/v/car/newenergyvehicle" } },
		{ { "title", "- 房车" }, { "url", "https://www.bilibili.com/v/car/touringcar" } },
		{ { "title", "- 摩托车" }, { "url", "https://www.bilibili.com/v/car/motorcycle" } },
		{ { "title", "- 购车攻略" }, { "url", "https://www.bilibili.com/v/car/strategy" } },
		{ { "title", "- 汽车生活" }, { "url", "https://www.bilibili.com/v/car/life" } },
		{ { "title", "时尚" }, { "url", "https://www.bilibili.com/v/fashion" } },
		{ { "title", "- 美妆护肤" }, { "url", "https://www.bilibili.com/v/fashion/makeup" } },
		{ { "title", "- 仿妆cos" }, { "url", "https://www.bilibili.com/v/fashion/cos" } },
		{ { "title", "- 穿搭" }, { "url", "https://www.bilibili.com/v/fashion/clothing" } },
		{ { "title", "- 时尚潮流" }, { "url", "https://www.bilibili.com/v/fashion/trend" } },
		{ { "title", "运动" }, { "url", "https://www.bilibili.com/v/sports" } },
		{ { "title", "- 篮球" }, { "url", "https://www.bilibili.com/v/sports/basketball" } },
		{ { "title", "- 足球" }, { "url", "https://www.bilibili.com/v/sports/football" } },
		{ { "title", "- 健身" }, { "url", "https://www.bilibili.com/v/sports/aerobics" } },
		{ { "title", "- 竞技 体育" }, { "url", "https://www.bilibili.com/v/sports/athletic" } },
		{ { "title", "- 运动文化" }, { "url", "https://www.bilibili.com/v/sports/culture" } },
		{ { "title", "- 运动综合" }, { "url", "https://www.bilibili.com/v/sports/comprehensive" } },
		{ { "title", "动物圈" }, { "url", "https://www.bilibili.com/v/animal" } },
		{ { "title", "- 喵星人" }, { "url", "https://www.bilibili.com/v/animal/cat" } },
		{ { "title", "- 汪星人" }, { "url", "https://www.bilibili.com/v/animal/dog" } },
		{ { "title", "- 小宠异宠" }, { "url", "https://www.bilibili.com/v/animal/reptiles" } },
		{ { "title", "- 野生动物" }, { "url", "https://www.bilibili.com/v/animal/wild_animal" } },
		{ { "title", "- 动物二创" }, { "url", "https://www.bilibili.com/v/animal/second_edition" } },
		{ { "title", "- 动物综合" }, { "url", "https://www.bilibili.com/v/animal/animal_composite" } },
		{ { "title", "搞笑" }, { "url", "https://www.bilibili.com/v/life/funny" } },
		{ { "title", "单机游戏" }, { "url", "https://www.bilibili.com/v/game/stand_alone" } },
	};
}

array<dictionary> PopularHistory() {
	array<dictionary> ret;
	string res = post("https://api.bilibili.com/x/web-interface/popular/series/list");
	if (res.empty()){
		return ret;
	}
	JsonReader Reader;
	JsonValue Root;
	if (Reader.parse(res, Root) && Root.isObject()) {
		if (Root["code"].asInt() != 0) {
			return ret;
		}
		JsonValue list = Root["data"]["list"];
		if (list.isArray()) {
			for (int i = 0; i < list.size(); i++) {
				dictionary week;
				week["title"] = list[i]["name"].asString() + " " + list[i]["subject"].asString();
				week["url"] = "https://www.bilibili.com/v/popular/weekly?num=" + list[i]["number"].asInt();
				ret.insertLast(week);
			}
		}
	}
	return ret;
}

array<dictionary> Other() {
	return {
		{ { "title", "首页推荐" }, { "url", "https://www.bilibili.com" } },
		{ { "title", "我关注的直播" }, { "url", "https://link.bilibili.com/p/center/index#/user-center/follow/1" } },
		{ { "title", "入站必刷" }, { "url", "https://www.bilibili.com/v/popular/history/" } },
		{ { "title", "搜索" }, { "url", "https://search.bilibili.com/video?keyword=陈奕迅" } },
		{ { "title", "稍后再看" }, { "url", "https://www.bilibili.com/watchlater/#/list" } },
		{ { "title", "历史记录" }, { "url", "https://www.bilibili.com/account/history" } },
		{ { "title", "动态首页" }, { "url", "https://t.bilibili.com" } },
	};
}

array<dictionary> GetCategorys()
{
	return {
		{ { "title", "分区 - 排行榜" }, { "Category", "Ranking" } },
		{ { "title", "分区 - 最新投稿" }, { "Category", "Dynamic" } },
		{ { "title", "每周必看" }, { "Category", "PopularHistory" } },
		{ { "title", "其他" }, { "Category", "Other" } },
	};
}

array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)
{
	if (Category == "Ranking") {
		return Ranking();
	}
	if (Category == "Dynamic") {
		return Dynamic();
	}
	if (Category == "PopularHistory") {
		return PopularHistory();
	}
	if (Category == "Other") {
		return Other();
	}

	array<dictionary> ret;
	return ret;
}
