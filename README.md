# BilibiliPotPlayer
适用于 PotPlayer 的 Bilibili 插件。

## 安装插件
[下载项目](https://github.com/chen310/BilibiliPotPlayer/archive/refs/heads/master.zip)

将项目 `Media/PlayParse` 路径下的 `MediaPlayParse - Bilibili.as` 和 `MediaPlayParse - Bilibili.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\PlayParse` 文件夹下。<br>
`MediaPlayParse - Bilibili.as` 提供了解析 `Bilibil` 链接的功能。<br>

将项目 `Media/UrlList` 路径下的 `MediaUrlList - Bilibili.as` 和 `MediaUrlList - Bilibili.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\UrlList` 文件夹下。<br>
`MediaUrlList - Bilibili.as` 提供了列出 `Bilibil` 常用链接的功能，使用方式为按下 <kbd>ctrl</kbd> + <kbd>U</kbd> 并选择要播放的项目，如下图所示<br>
![UrlList](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/urllist.png)<br>

## 登录
打开 PotPlayer，按 <kbd>F5</kbd> 打开选项，点击`扩展功能`下的`媒体播放列表/项目`，再点击 `Bilibili`，然后打开账户设置，在 `Cookie` 一栏粘贴你的 Bilibili Cookie。<br>
![Login](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/login.png)<br>
点击测试按钮，如果弹出账号信息，就说明登录成功。<br>
![Test](https://cdn.jsdelivr.net/gh/chen310/BilibiliPotPlayer/public/test.png)<br>
如果 Cookie 是从浏览器上复制来的，登录成功后，到浏览器中把 Bilibili 的 Cookie 删除，再重新到浏览器上登录，不然 PotPlayer 中的 Cookie 可能会很快失效（大概吧，我也不确定）<br>
### Cookies获取
<small>参阅：<a href="https://github.com/XiaoMiku01/bili-live-heart/blob/master/doc_old/bili.md">B站Cookie获取教程</a></small>
- 打开你所用浏览器的**无痕模式**  <br>**如果还是抓不到就把无痕模式关了再试试！**
- 第二步：  
  - 在**无痕窗口**进入任意一个直播间  
  - 在直播间页面点击右上角登录自己的B站账号  
- 第三步：  
  - 点击键盘`F12`或者`鼠标右键`->检查，进入开发者工具  
  - 点击`网络`/`NetWork`选项卡  <br>
  ![网络/Network](http://i0.hdslb.com/bfs/album/4717448339d26a412ba23215d3ce674c549adf4f.png)  
  - 进入该选项卡后，键盘`F5`或浏览器左上角刷新页面  
  - 在数据包中找到**heartBeat**或**webHeartBeat**，点击找到请求头中的**cookie**项，并复制保留（图中浅蓝色部分）后面部署会用到这个cookie  <br>
  ![cookie](http://i0.hdslb.com/bfs/album/01c052ec17757a34f6a256f03523efa89c3e4d56.jpg)  

PS:有了cookie能操作B站账号的大部分功能，切勿泄露或分享出去<br>
**如果后续出现报错,请关闭无痕模式抓cookie**
## 使用方法
将 Bilibili 视频链接拖到 PotPlayer，或者按 <kbd>ctrl</kbd> + <kbd>U</kbd> 粘贴 Bilibili 视频链接即可播放。<br>
