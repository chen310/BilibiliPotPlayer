# BilibiliPotPlayer

适用于 PotPlayer 的 Bilibili 插件。如果配合[油猴脚本](https://greasyfork.org/zh-CN/scripts/461800-bilibilipotplayer)，可以直接在网页打开 PotPlayer 进行播放

## 安装插件

[下载项目](https://github.com/chen310/BilibiliPotPlayer/archive/refs/heads/master.zip)

将项目 `Media/PlayParse` 路径下的 `MediaPlayParse - Bilibili.as` 和 `MediaPlayParse - Bilibili.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\PlayParse` 文件夹下。

`MediaPlayParse - Bilibili.as` 提供了解析 `Bilibili` 链接的功能。

将项目 `Media/UrlList` 路径下的 `MediaUrlList - Bilibili.as` 和 `MediaUrlList - Bilibili.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\UrlList` 文件夹下。

`MediaUrlList - Bilibili.as` 提供了列出 `Bilibili` 常用链接的功能，使用方式为按下 <kbd>ctrl</kbd> + <kbd>U</kbd> 并选择要播放的项目，如下图所示

![UrlList](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/urllist.png)

## 登录

打开 PotPlayer，按 <kbd>F5</kbd> 打开选项，点击`扩展功能`下的`媒体播放列表/项目`，再点击 `Bilibili`，然后打开`账户设置`，在 `Cookie` 一栏粘贴你的 Bilibili Cookie。

![Login](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/login.png)

点击测试按钮，如果弹出账号信息，就说明登录成功。

![Test](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/test.png)

### Cookies 获取

<small>参阅：<a href="https://github.com/XiaoMiku01/bili-live-heart/blob/master/doc_old/bili.md">B 站 Cookie 获取教程</a></small>

- 打开你所用浏览器的**无痕模式**
  **如果还是抓不到就把无痕模式关了再试试！**
- 第二步：
  - 在**无痕窗口**进入任意一个直播间
  - 在直播间页面点击右上角登录自己的 B 站账号
- 第三步：

  - 点击键盘`F12`或者`鼠标右键`->检查，进入开发者工具
  - 点击`网络`/`NetWork`选项卡

  ![网络/Network](http://i0.hdslb.com/bfs/album/4717448339d26a412ba23215d3ce674c549adf4f.png)

  - 进入该选项卡后，键盘`F5`或浏览器左上角刷新页面
  - 在数据包中找到 **heartBeat** 或 **webHeartBeat**，点击找到请求头中的 **cookie** 项，并复制保留（图中浅蓝色部分）填写到插件账号设置的 Cookie 一栏中

  ![cookie](http://i0.hdslb.com/bfs/album/01c052ec17757a34f6a256f03523efa89c3e4d56.jpg)

PS:有了 cookie 能操作 B 站账号的大部分功能，切勿泄露或分享出去

**如果后续出现报错,请关闭无痕模式抓 cookie**

## 使用方法

### 播放视频/直播

将 Bilibili 链接拖到 PotPlayer，或者按 <kbd>ctrl</kbd> + <kbd>U</kbd> 粘贴 Bilibili 链接即可播放。可参考[视频](https://www.bilibili.com/video/BV1mM41177kT)

### 搜索

按 <kbd>ctrl</kbd> + <kbd>U</kbd>，在文件地址列表中选择`搜索`，然后到上面的输入框中替换关键词，最后回车即可

![Search](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/search.png)

### 跳过片头片尾

对于一些电视剧、番剧，能够跳过片头和片尾。具体设置为：在 PotPlayer 上点击鼠标右键，选择`播放`-`跳略播放`-`跳略播放设置`

![Skip_Settings](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/skip_1.png)

勾选`跳略播放`和`章节名称`，并在名称列表中追加`哔哩哔哩-片头`和`哔哩哔哩-片尾`两项，每一项之间用英文分号`;`隔开。

![Skip_Settings](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/skip_2.png)

### 在列表中显示缩略图

按 <kbd>F6</kbd> 打开播放列表，点击鼠标右键，点击`样式`，选择`显示缩略图`，即可显示视频的缩略图。

![Thumbnail](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/thumbnail.png)

### 创建自动更新的播放列表

按 <kbd>F6</kbd> 打开播放列表，点击新建专辑，起一个合适的专辑名称，选择外部播放列表，并填写相应的链接，再点击确定即可。这样就得到一个可以自动更新的列表。

![Create_Playlist](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/create_playlist_1.png)

![Create_Playlist](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/create_playlist_2.png)
