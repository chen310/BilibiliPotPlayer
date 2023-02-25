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

array<dictionary> Ranking() {
	array<dictionary> ret;
	array<string> urls = { "https://www.bilibili.com/v/popular/rank/all", "https://www.bilibili.com/v/popular/rank/guochuang", "https://www.bilibili.com/v/popular/rank/douga", "https://www.bilibili.com/v/popular/rank/music", "https://www.bilibili.com/v/popular/rank/dance", "https://www.bilibili.com/v/popular/rank/game", "https://www.bilibili.com/v/popular/rank/knowledge", "https://www.bilibili.com/v/popular/rank/tec", "https://www.bilibili.com/v/popular/rank/spor", "https://www.bilibili.com/v/popular/rank/car", "https://www.bilibili.com/v/popular/rank/life", "https://www.bilibili.com/v/popular/rank/food", "https://www.bilibili.com/v/popular/rank/animal", "https://www.bilibili.com/v/popular/rank/kichiku", "https://www.bilibili.com/v/popular/rank/fashion", "https://www.bilibili.com/v/popular/rank/en", "https://www.bilibili.com/v/popular/rank/cinephile" };
	array<string> names = { "全站", "国创相关", "动画", "音乐", "舞蹈", "游戏", "知识", "科技", "运动", "汽车", "生活", "美食", "动物圈", "鬼畜", "时尚", "娱乐", "影视" };
	for (uint i = 0; i < urls.size(); i++) {
		dictionary channel;
		channel["title"] = names[i];
		channel["url"] = urls[i];
		ret.insertLast(channel);
	}
	return ret;
}

array<dictionary> Dynamic() {
	array<dictionary> ret;
	array<string> urls = { 'https://www.bilibili.com/anime/', 'https://www.bilibili.com/v/anime/serial/', 'https://www.bilibili.com/v/anime/finish', 'https://www.bilibili.com/v/anime/information/', 'https://www.bilibili.com/v/anime/offical/', 'https://www.bilibili.com/movie/', 'https://www.bilibili.com/guochuang/', 'https://www.bilibili.com/v/guochuang/chinese/', 'https://www.bilibili.com/v/guochuang/original/', 'https://www.bilibili.com/v/guochuang/puppetry/', 'https://www.bilibili.com/v/guochuang/motioncomic/', 'https://www.bilibili.com/v/guochuang/information/', 'https://www.bilibili.com/tv/', 'https://www.bilibili.com/documentary/', 'https://www.bilibili.com/v/douga/', 'https://www.bilibili.com/v/douga/mad/', 'https://www.bilibili.com/v/douga/mmd/', 'https://www.bilibili.com/v/douga/voice/', 'https://www.bilibili.com/v/douga/garage_kit/', 'https://www.bilibili.com/v/douga/tokusatsu/', 'https://www.bilibili.com/v/douga/acgntalks/', 'https://www.bilibili.com/v/douga/other/', 'https://www.bilibili.com/v/game/', 'https://www.bilibili.com/v/game/stand_alone', 'https://www.bilibili.com/v/game/esports', 'https://www.bilibili.com/v/game/mobile', 'https://www.bilibili.com/v/game/online', 'https://www.bilibili.com/v/game/board', 'https://www.bilibili.com/v/game/gmv', 'https://www.bilibili.com/v/game/music', 'https://www.bilibili.com/v/game/mugen', 'https://www.bilibili.com/v/kichiku/', 'https://www.bilibili.com/v/kichiku/guide', 'https://www.bilibili.com/v/kichiku/mad', 'https://www.bilibili.com/v/kichiku/manual_vocaloid', 'https://www.bilibili.com/v/kichiku/theatre', 'https://www.bilibili.com/v/kichiku/course', 'https://www.bilibili.com/v/music', 'https://www.bilibili.com/v/music/original', 'https://www.bilibili.com/v/music/cover', 'https://www.bilibili.com/v/music/perform', 'https://www.bilibili.com/v/music/vocaloid', 'https://www.bilibili.com/v/music/live', 'https://www.bilibili.com/v/music/mv', 'https://www.bilibili.com/v/music/commentary', 'https://www.bilibili.com/v/music/tutorial', 'https://www.bilibili.com/v/music/other', 'https://www.bilibili.com/v/dance/', 'https://www.bilibili.com/v/dance/otaku/', 'https://www.bilibili.com/v/dance/hiphop/', 'https://www.bilibili.com/v/dance/star/', 'https://www.bilibili.com/v/dance/china/', 'https://www.bilibili.com/v/dance/three_d/', 'https://www.bilibili.com/v/dance/demo/', 'https://www.bilibili.com/v/cinephile', 'https://www.bilibili.com/v/cinephile/cinecism', 'https://www.bilibili.com/v/cinephile/montage', 'https://www.bilibili.com/v/cinephile/shortfilm', 'https://www.bilibili.com/v/cinephile/trailer_info', 'https://www.bilibili.com/v/ent/', 'https://www.bilibili.com/v/ent/variety', 'https://www.bilibili.com/v/ent/talker', 'https://www.bilibili.com/v/ent/fans', 'https://www.bilibili.com/v/ent/celebrity', 'https://www.bilibili.com/v/knowledge/', 'https://www.bilibili.com/v/knowledge/science', 'https://www.bilibili.com/v/knowledge/social_science', 'https://www.bilibili.com/v/knowledge/humanity_history', 'https://www.bilibili.com/v/knowledge/business', 'https://www.bilibili.com/v/knowledge/campus', 'https://www.bilibili.com/v/knowledge/career', 'https://www.bilibili.com/v/knowledge/design', 'https://www.bilibili.com/v/knowledge/skill', 'https://www.bilibili.com/v/tech/', 'https://www.bilibili.com/v/tech/digital', 'https://www.bilibili.com/v/tech/application', 'https://www.bilibili.com/v/tech/computer_tech', 'https://www.bilibili.com/v/tech/industry', 'https://www.bilibili.com/v/information/', 'https://www.bilibili.com/v/information/hotspot', 'https://www.bilibili.com/v/information/global', 'https://www.bilibili.com/v/information/social', 'https://www.bilibili.com/v/information/multiple', 'https://www.bilibili.com/v/food', 'https://www.bilibili.com/v/food/make', 'https://www.bilibili.com/v/food/detective', 'https://www.bilibili.com/v/food/measurement', 'https://www.bilibili.com/v/food/rural', 'https://www.bilibili.com/v/food/record', 'https://www.bilibili.com/v/life', 'https://www.bilibili.com/v/life/funny', 'https://www.bilibili.com/v/life/parenting', 'https://www.bilibili.com/v/life/travel', 'https://www.bilibili.com/v/life/rurallife', 'https://www.bilibili.com/v/life/home', 'https://www.bilibili.com/v/life/handmake', 'https://www.bilibili.com/v/life/painting', 'https://www.bilibili.com/v/life/daily', 'https://www.bilibili.com/v/car', 'https://www.bilibili.com/v/car/racing', 'https://www.bilibili.com/v/car/modifiedvehicle', 'https://www.bilibili.com/v/car/newenergyvehicle', 'https://www.bilibili.com/v/car/touringcar', 'https://www.bilibili.com/v/car/motorcycle', 'https://www.bilibili.com/v/car/strategy', 'https://www.bilibili.com/v/car/life', 'https://www.bilibili.com/v/fashion', 'https://www.bilibili.com/v/fashion/makeup', 'https://www.bilibili.com/v/fashion/cos', 'https://www.bilibili.com/v/fashion/clothing', 'https://www.bilibili.com/v/fashion/trend', 'https://www.bilibili.com/v/sports', 'https://www.bilibili.com/v/sports/basketball', 'https://www.bilibili.com/v/sports/football', 'https://www.bilibili.com/v/sports/aerobics', 'https://www.bilibili.com/v/sports/athletic', 'https://www.bilibili.com/v/sports/culture', 'https://www.bilibili.com/v/sports/comprehensive', 'https://www.bilibili.com/v/animal', 'https://www.bilibili.com/v/animal/cat', 'https://www.bilibili.com/v/animal/dog', 'https://www.bilibili.com/v/animal/reptiles', 'https://www.bilibili.com/v/animal/wild_animal', 'https://www.bilibili.com/v/animal/second_edition', 'https://www.bilibili.com/v/animal/animal_composite', 'https://www.bilibili.com/v/life/funny', 'https://www.bilibili.com/v/game/stand_alone' };
	array<string> names = { '番剧', '- 连载动画', '- 完结动画', '- 资讯', '- 官方延伸', '电影', '国创', '- 国产动画', '- 国产原创相关', '- 布袋戏', '- 动态漫·广播剧', '- 资讯', '电视剧', '纪录片', '动画', '- MAD·AMV', '- MMD·3D', '- 短片·手书·配音', '- 手办·模玩', '- 特摄', '- 动漫杂谈', '- 综合', '游戏', '- 单机游戏', '- 电子竞技', '- 手机游戏', '- 网络游戏', '- 桌游棋牌', '- GMV', '- 音游', '- Mugen', '鬼畜', '- 鬼畜调教', '- 音MAD', '- 人力VOCALOID', '- 鬼畜剧场', '- 教程演示', '音乐', '- 原创音乐', '- 翻唱', '- 演奏', '- VOCALOID·UTAU', '- 音乐现场', '- MV', '- 乐评盘点', '- 音乐教学', '- 音乐综合', '舞蹈', '- 宅舞', '- 街舞', '- 明星舞蹈', '- 中国舞', '- 舞蹈综合', '- 舞蹈教程', '影视', '- 影视杂谈', '- 影视剪辑', '- 小剧场', '- 预告·资讯', '娱乐', '- 综艺', '- 娱乐杂谈', '- 粉丝创作', '-  明星综合', '知识', '- 科学科普', '- 社科·法律·心理', '- 人文历史', '- 财经商业', '- 校园学习', '- 职业职场', '- 设计·创意', '- 野生技能协会', '科技', '- 数 码', '- 软件应用', '- 计算机技术', '- 科工机械', '资讯', '- 热点', '- 环球', '- 社会', '- 综合', '美食', '- 美食制作', '- 美食侦探', '- 美食测评', '- 田园美食', '- 美食记录', '生活', '- 搞笑', '- 亲子', '- 出行', '- 三农', '- 家居房产', '- 手工', '- 绘画', '- 日常', '汽车', '- 赛车', '- 改装玩车', '- 新能源车', '- 房车', '- 摩托车', '- 购车攻略', '- 汽车生活', '时尚', '- 美妆护肤', '- 仿妆cos', '- 穿搭', '- 时尚潮流', '运动', '- 篮球', '- 足球', '- 健身', '- 竞技 体育', '- 运动文化', '- 运动综合', '动物圈', '- 喵星人', '- 汪星人', '- 小宠异宠', '- 野生动物', '- 动物二创', '- 动物综合', '搞笑', '单机游戏' };
	for (uint i = 0; i < urls.size(); i++) {
		dictionary channel;
		channel["title"] = names[i];
		channel["url"] = urls[i];
		ret.insertLast(channel);
	}
	return ret;
}

array<dictionary> Other() {
	array<dictionary> ret;
	array<string> urls = { "https://www.bilibili.com", "https://link.bilibili.com/p/center/index#/user-center/follow/1" };
	array<string> names = { "首页推荐", "我关注的直播" };
	for (uint i = 0; i < urls.size(); i++) {
		dictionary channel;
		channel["title"] = names[i];
		channel["url"] = urls[i];
		ret.insertLast(channel);
	}
	return ret;
}

array<dictionary> GetCategorys()
{
	array<dictionary> ret;

	{
		dictionary item;
		item["title"] = "分区 - 排行榜";
		item["Category"] = "Ranking";
		ret.insertLast(item);
	}
	{
		dictionary item;
		item["title"] = "分区 - 最新投稿";
		item["Category"] = "Dynamic";
		ret.insertLast(item);
	}
	{
		dictionary item;
		item["title"] = "其它";
		item["Category"] = "Other";
		ret.insertLast(item);
	}

	return ret;
}

array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)
{
	if (Category == "Ranking") {
		return Ranking();
	}
	if (Category == "Dynamic") {
		return Dynamic();
	}
	if (Category == "Other") {
		return Other();
	}	

	array<dictionary> ret;
	return ret;
}
