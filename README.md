# xiaozhi esp32 godot client 
小智esp32 godot 客户端

## 主要功能
- 基于VRM的模型，实现小智的动画
- 目前已经实现能连接到小智esp32 server
- 添加了android平台下opus库的支持，能够顺利在android端运行。
- 能够根据服务器返回的emotion，播放指定动画
- 嘴部实现了实时的发音动画
- 已经编译好win和android下的人脸识别模块,基于ncnn
- 正在加入动作生成后端的支持，能够实现根据指令生成动作，后端的方法来自于[momask-codes](https://github.com/EricGuo5513/momask-codes)
- 限于个人水平，在解析bvh到godot的动画时，可能存在一些问题，手部动作动作扭曲
- 
[GitHub仓库链接](https://github.com/jjp9624022/xiaozhi-godot-client)
