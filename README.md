# TrackCamera-GMV

#### 介绍
Apai Go ios
- 基于谷歌GMV的人脸识别相机拍摄/录制应用，此项目为一个赶工拼凑之作，虽已上架但实体流产。。。本着互相学习的态度，开源出来供有需求的参考参考

- 人脸识别框架可灵活替换为国内的一些厂商的,Arc什么的,识别效率可自行比较
本项目为一锤子项目，后续不会维护更新，大家当作一个练手人脸识别、相机拍照、录制的demo看待

- 初始主体基于Photolyze 作者：lammax 链接 https://github.com/lammax/Photolyze.git
- 主体滤镜基于BBMetalImage 作者：Silence-GitHub  链接 https://github.com/Silence-GitHub/BBMetalImage.git
- 动画框架Tweener 作者：alexrvarela 链接 https://github.com/alexrvarela/SwiftTweener.git
- 权限框架SPPermissions 作者：varabeis 链接 https://github.com/varabeis/SPPermissions.git
- 音效框架Soundable 作者：ThXou 链接 https://github.com/ThXou/Soundable.git
- 网络框架AFNetworking  作者：AFNetworking 链接 https://github.com/AFNetworking/AFNetworking.git
- AES加密框架CryptoSwift 作者：krzyzanowskim 链接 https://github.com/krzyzanowskim/CryptoSwift.git
- 弹框框架Pow 作者：Meniny 链接 https://github.com/Meniny/Pow.git
- 图片格式转换libyuv-iOS 
- 相册框架DLPhotoPicker 作者：darling0825 链接 https://github.com/darling0825/DLPhotoPicker.git


#### 软件架构
软件架构说明
基于swift 5,包含些许Objective-C三方库引用

#### 安装+使用教程

1.  pod install
2.  安装依赖后，新版Xcode选择 **legacy build system** 运行(可能是某个库导致必须用legacy运行)
3. 人脸识别框架切换修改入口FilteredCameraBBMetalEXxxx(FilteredCameraBBMetalEXARC、FilteredCameraBBMetalEXML...)


#### 使用截图
- 滤镜
![滤镜演示](https://images.gitee.com/uploads/images/2021/0316/115109_34bc1f5a_798938.gif "app-demo1.gif")

- 人脸识别
![输入图片说明](https://images.gitee.com/uploads/images/2021/0316/120406_3707dd64_798938.gif "ezgif.com-gif-maker.gif")
