//
//  FilteredCamera.swift
//  Photolyze
//
//  Created by Mac on 06.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import CoreVideo
import AVFoundation
import Tweener
//import BBMetalImage


@objc protocol FilteredCameraBBMetalDelegate {
    @objc optional  func filteredCamera(didUpdate image: CIImage)
    @objc optional  func videoCapture(_ capture: FilteredCameraBBMetal, didCaptureVideoTexture texture: MTLTexture?, timestamp: CMTime)
    //    mlmnodel
    @objc optional func videoCapture(_ capture: FilteredCameraBBMetal, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
    
    func metaCapture(_ capture: FilteredCameraBBMetal,faceBoxes:NSMutableArray, didOutputMetadataObjects: [AVMetadataObject])
    //方向\快慢与距离
    @objc optional func faceMove(_ direction:BLE_order.Direction,distance:CGFloat)
    
}


class FilteredCameraBBMetal: NSObjectExMetal{
    
    var delegate: FilteredCameraBBMetalDelegate?
    
    //    private let type: FilterType?
    public var camera: BBMetalCameraEx!
    public var metalView: BBMetalView!
    //    private var imageSource: BBMetalStaticImageSource?
    private var videoWriter: BBMetalVideoWriter!
    private var filePath: String!
    
    var parentView:UIView?
    
    //    var facesViewArr = NSMutableArray.init(capacity: 0)
    
    public var faceView: UIView!
    
    //初始点为屏幕中心点
    public var centerPos:CGPoint!
    public var centerPosStatic:CGPoint!
    public var distance:CGFloat = 0//与中心点的距离
    
    //  移动容差,5像素点
    public var deltDistance:CGFloat = 5
    //    init(type: FilterType) {
    //        self.type = type
    //        super.init()//放后面？
    //    }
    
    
    var addFilters_Queue = DispatchQueue.init(label: "addFilters_Queue")
    var sendOrder_Queue = DispatchQueue.init(label: "sendOrder_Queue")
    let semaphoreFilter = DispatchSemaphore(value: 1)
    
    let loadImageOperation = OperationQueue()
    
    
    
    init(view: UIView) {
        super.init()
        //加载耗时-background:6s\userInteractive:2.7s\userInitiated:2.8s\utility:3.0s
        //        loadImageOperation.qualityOfService = .background
        loadImageOperation.qualityOfService = .userInitiated
        loadImageOperation.maxConcurrentOperationCount = 5
        setUp(contentView: view)
    }
    
    public func setUp(contentView:UIView){
        
        centerPos = contentView.center
        centerPosStatic = contentView.center
        parentView = contentView
        //        let preRect = CGRect(x:0, y:self.parentView!.frame.height, width:self.parentView!.frame.width, height:50)--为了动画
        let preRect = CGRect(x:0, y:0, width:self.parentView!.frame.width, height:self.parentView!.frame.height)
        metalView = BBMetalView(frame:preRect)
        //        contentView.addSubview(metalView)//预览界面
        contentView.insertSubview(metalView, at: 0)
        
        
        
        
        faceView = UIView(frame: .zero)
        //        faceView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        faceView.layer.borderWidth = 3
        faceView.backgroundColor = UIColor.clear
        metalView.addSubview(faceView)
        
        
        filePath = NSTemporaryDirectory() + "lc.mp4"
        let url = URL(fileURLWithPath: filePath)
        //        camera = BBMetalCameraEx(sessionPreset: .hd1920x1080)
        if(Global.isIpad() || Global.isOnlySurport720P()){
            videoWriter = BBMetalVideoWriter(url: url, frameSize: BBMetalIntSize(width: 720, height: 1280))
            camera = BBMetalCameraEx(sessionPreset: .high)
        }else{
            videoWriter = BBMetalVideoWriter(url: url, frameSize: BBMetalIntSize(width: 1080, height: 1920))
            camera = BBMetalCameraEx(sessionPreset: .high)
        }
        camera.audioConsumer = videoWriter
        
        
        camera.canTakePhoto = true
        camera.photoDelegate = self
        
        if(APP_faceEngine == FaceEngine.ARC){
            camera.videoDelegate = self//ARC
            faceView.layer.borderColor = Theme_COLOR.cgColor
            //            faceView.layer.borderColor = TGCameraColor.tintColor()?.cgColor
            
        }else{
            //自带AVFoundation人脸识别
            faceView.layer.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            
            camera.addMetadataOutput(with: [AVMetadataObject.ObjectType.face])
            camera.metadataObjectDelegate = self
        }
        
        
        camera.add(consumer: metalView)
        camera.add(consumer: videoWriter)
        contentView.addTapGestureRecognizer { (tap) in
            print("tapAction-contentView\(tap)")
            let touchPoint = tap.location(in: contentView)
            let viewTop = contentView.viewWithTag(1232)
            let viewBottom = contentView.viewWithTag(1231)
            if((viewTop?.frame.maxY)! < touchPoint.y && (viewBottom?.frame.minY)! > touchPoint.y){
                TGCameraFocus.focus(with: self.camera.session, touch: touchPoint, inFocus: contentView)
                //苹果审核
//                if(touchPoint.x > contentView.center.x){
//                    self.delegate?.faceMove?(BLE_order.Direction.Right,distance:1)
//                }else{
//                    self.delegate?.faceMove?(BLE_order.Direction.Hold_Left,distance:1)
//                    
//                }
            }
            
            
        }
        cameraStart()
        //        shapePathAnim(view:metalView)
        
    }
    
    
    private func shapePathAnim(view:UIView){
        //Create tween
        let tween:Tween = Tween(target:view,//Target
            duration:0.7,//One second
            ease:Ease.inOutCubic,
            keys:[\UIView.alpha:1.0,
                  \UIView.frame:CGRect(x:0, y:0, width:self.parentView!.frame.width, height:self.parentView!.frame.height),
                  //This property is an optional.
                //                            \UIView.backgroundColor!:UIColor.red
        ])
        
        //Add tween
        tween.onComplete = {
            print("Tween complete")
        }
        
        tween.play()
    }
    
    
    //viewDidAppear
    public func cameraStart(){
        if(camera == nil){
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .videoRecording, options: [])
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        camera.start()
        
    }
    //viewDidDisappear
    public func cameraStop(){
        if(camera == nil){
            return
        }
        camera.stop()
    }
    
    
    //viewDidDisappear
    public func cameraSwitch(){
        if(camera == nil){
            return
        }
        if(camera.position == .back){
            self.camera._updateIlluminationMode(self.camera.flashMode)
        }
        self.faceView.isHidden = true
        camera.switchCameraPosition()
        
    }
    
    //    var currentFilter = FilterType.none
    //    BBMetalBaseFilter
    
    var currentFilter:BBMetalBaseFilter?
    public func addFilter(type:FilterType){
        
        
        let addOp = BlockOperation()
        addOp.addExecutionBlock {
            //            self.semaphoreFilter.wait()
            
            //            if(self.currentFilter == type){//防止重复添加
            //                print("addFilter-repeat")
            //                return
            //            }
            if(self.currentFilter != nil){
                if(self.currentFilter!.name.lowercased().contains(type.name().lowercased())){
                    return
                }
                //                important,防止视频帧通道阻塞
                self.currentFilter?.removeAllConsumers()
                self.currentFilter?.removeAllCompletedHandlers()
            }
            print("addFilter-semaphoreFilter\(type)")
            
            self.camera.removeAllConsumers()
            //        camera.add(consumer: metalView)
            self.camera.willTransmitTexture = nil
            //            self.imageSource = nil
            var imageSource: BBMetalStaticImageSource? //移入局部
            //        camera.add(consumer: videoWriter)
            //            self.currentFilter = type
            //        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2) {
            
            
            
            let filter = filterItemsVideo.filter({ (item) -> Bool in
                //                       print("filterItems\(item!.name)")
                
                if(type == FilterType.none){
                    return item == nil
                }else{
                    
                    //                    print("filterItems-\(item!.name)")
                    if(item == nil){
                        return false
                    }else{
                        print("filterItems-\(item!.name)")
                        return item!.name.lowercased().contains(type.name().lowercased())
                    }
                    
                    //                    return item != nil && item!.name.contains(type.name())
                }
                
                //                if(item == nil && type == FilterType.none){//无滤镜
                //                    return true
                //                }else{
                //                    return item!.name.contains(type.name())
                //
                //                }
            })
            print("filterItems-re-\(filter)")
            
            if( filter.count > 0 && filter[0] != nil ){
                self.currentFilter = filter[0]
                
                
                self.camera.add(consumer: filter[0]!).add(consumer:self.metalView)
                filter[0]!.add(consumer: self.videoWriter)
                
                if let source = imageSource {
                    self.camera.willTransmitTexture = { [weak self] texture in
                        guard self != nil else { return }
                        return source.transmitTexture()
                    }
                    source.add(consumer: filter[0]!)
                }
                
            }else{
                self.currentFilter = nil
                self.camera.add(consumer: self.metalView)
                self.camera.willTransmitTexture = nil
                //                self.imageSource = nil
                imageSource = nil
                self.camera.add(consumer: self.videoWriter)
            }
            //            self.semaphoreFilter.signal()
            
            //        }
            
            
        }
        loadImageOperation.addOperation(addOp)
    }
    
    public func takePhoto(){
        if(camera == nil){
            return
        }
        //        camera.takePhoto()
        camera.takePhotoWithFlash()
    }
    
    //    var isNeedFlash = false
    
    typealias SetAutoFlash = (Bool)->Void
    
    var setAutoFlashVar:SetAutoFlash?
    
    
    func setAutoFlashFunc(ac:@escaping SetAutoFlash){
        self.setAutoFlashVar = ac
    }
    
    
    
    public func recordVideo(button:UIButton){
        let timeLabel = self.parentView?.viewWithTag(123)
        
        setAutoFlashFunc { (isAutoFlash) in
            //            let t = self.camera.flashMode
            if(isAutoFlash && self.camera.flashMode == .auto){
                self.camera._updateIlluminationMode(CameraFlashMode.on)
                //                self.setAutoFlashVar = nil
            }
        }
        
        if button.isSelected {
            //            button.isHidden = true
            try? FileManager.default.removeItem(at: videoWriter.url)
            //            videoWriter.cancel()
            videoWriter.start { (type) in
                //                switch type {
                //                case let .video(time, success): print("Video time = \(time), success = \(success)")
                //                case let .audio(time, success): print("Audio time = \(time), success = \(success)")
                //                }
                
                RecordTimeCounterGCD.sharedInstance.startTimeCounter { (timeStr) in
                    DispatchQueue.main.async {
                        if let timeLabel = (timeLabel as? UILabel){
                            timeLabel.isHidden = false
                            //                            timeLabel.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightRegular]
                            //                            timeLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: UIFont.Weight.regular)//等宽，防止波动
                            //                            timeLabel.font = UIFont.init(name: "Helvetica", size: 16)//等宽字体
                            //                            [UIFont fontWithName:@"Helvetica" size:16]
                            timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.regular)
                            timeLabel.text = timeStr
                        }
                    }
                }
            }
            
        } else {
            
            if( self.camera.flashMode == .auto){
                self.setAutoFlashVar = nil
                self.camera._updateIlluminationMode(CameraFlashMode.off)
            }
            videoWriter.finish { [weak self] in
                DispatchQueue.global().async {
                    guard let self = self else { return }
                    RecordTimeCounterGCD.sharedInstance.stopTimer()
                    UISaveVideoAtPathToSavedPhotosAlbum(self.videoWriter.url.path, self, #selector(self.handleDidCompleteSavingToLibrary(path:error:contextInfo:)), nil)
                }
                DispatchQueue.main.async {
                    if((timeLabel as? UILabel) != nil){
                        (timeLabel as! UILabel).isHidden = true
                        (timeLabel as! UILabel).text = "00:00:00"
                    }
                }
                
            }
        }
    }
    
    @objc func handleDidCompleteSavingToLibrary(path: String?, error: Error?, contextInfo: Any?) {
        if error != nil{
            
            let showMessage = "保存失败"
            self.showMsg(msg: showMessage)
            
        }
    }
    
    
    
    
    func showMsg(msg:String){
        
        //        SVProgressHUD
        SVProgressHUD.setMaximumDismissTimeInterval(1)
        SVProgressHUD.showError(withStatus:msg)
        //                DLProgressHud.showSuccessStatus(msg)
        
        
    }
    
    
    /**
     指令发送入口
     */
    func orderSendWrap(_ frameFace:CGRect? = nil){
        
        if let frame = frameFace{
            //算与中心点的距离
            self.sendOrder_Queue.async {
                
                var direction = BLE_order.Direction.Hold_Left
                //                let tDis = abs(sqrt(pow((frame.midX - self.centerPosStatic.x), 2) + pow((frame.midY - self.centerPosStatic.y), 2)))
                //                let isInCenter = tDis < 30
                
                if(deviceOrientation == TgDirection.directionPortrait){
                    print("sendOrder_Queue-竖>>\(frame.midX)>>\(self.centerPos.x)")
                    self.distance = frame.midX - self.centerPos.x
                    
                    if(frame.midX - self.centerPos.x > self.deltDistance){//右边
                        direction = BLE_order.Direction.Right
                    }else if(frame.midX - self.centerPos.x < self.deltDistance){
                        direction = BLE_order.Direction.Hold_Left
                    }
                    //                    self.centerPos = CGPoint.init(x:frame.midX , y: frame.midY)
                }else{
                    print("sendOrder_Queue-横\(deviceOrientation.rawValue)>>\(frame.midX)>\(frame.midY)>>\(String(describing: self.centerPos))")
                    self.distance = frame.midY - self.centerPos.y
                    
                    if(deviceOrientation.rawValue == 4){
                        //             sendOrder_Queue-横4>>163.30040624999998>163.30040624999998>>Optional((391.1955,163.30040624999998))
                        if(frame.midY - self.centerPos.y > self.deltDistance){//右边
                            direction = BLE_order.Direction.Right
                        }else if(frame.midY - self.centerPos.y < self.deltDistance){
                            direction = BLE_order.Direction.Hold_Left
                        }
                        
                    }else if(deviceOrientation.rawValue == 3){
                        //                            sendOrder_Queue-横3>>221.266875>221.266875>>Optional((418.209, 221.266875))
                        if(frame.midY - self.centerPos.y > self.deltDistance){//左
                            direction = BLE_order.Direction.Hold_Left
                        }else if(frame.midY - self.centerPos.y < self.deltDistance){
                            direction = BLE_order.Direction.Right
                            
                        }
                    }
                    //                    self.centerPos = CGPoint.init(x:frame.midX , y: frame.midY)
                }
                
                //过滤
                var moveDis = abs(self.distance)
                
                
                //与屏幕中心点大体重合才停止
                //                //public func pow(_: Double, _: Double) -> Double
                //                        //pow()函数是求次方的
                //
                //                        //public func sqrt(_: Double) -> Double
                //                        //sqrt()函数是求平方根的
                //                        let distance = sqrt(pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2))
                //
                //                ————————————————
                //                版权声明：本文为CSDN博主「文件夹_IOS」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
                //                原文链接：https://blog.csdn.net/u010130947/article/details/50978646
                //                let isInCenter = abs(frame.midX + frame.midY - self.centerPosStatic.x - self.centerPosStatic.y) < self.deltDistance
                
//                let isInCenter = moveDis < 15
                let isInCenter = moveDis < 27 //放大阙值
                
                if(isInCenter){//这才停
                    moveDis = 0
                }else{
                    moveDis = 11
                    
                }
                
                //                if(moveDis < self.deltDistance && isInCenter){//停
                //                    moveDis = 0
                //                }
                if(self.camera != nil){//前置才翻转
                    if(direction == .Hold_Left){
                        direction = .Right
                    }else{
                        direction = .Hold_Left
                    }
                }
                
                
                print("faceMove-isInCenter-->\(moveDis)-->\(String(describing: self.centerPosStatic))-->\(String(describing: self.centerPos))")
                if(APP == APP_ver.Test){
                    DispatchQueue.main.async {
                        SVProgressHUD.setBackgroundColor(UIColor.white)
                        if(direction == .Hold_Left){
                            
                            if(moveDis < self.deltDistance ){//停
                                SVProgressHUD.showInfo(withStatus: "停>"+moveDis.description)
                                
                            }else{
                                SVProgressHUD.showInfo(withStatus: "LL>"+moveDis.description)
                                
                            }
                        }else{
                            SVProgressHUD.showInfo(withStatus: "RR>"+moveDis.description)
                        }
                        
                        
                        
                    }
                }
                
                
                
                self.delegate?.faceMove?(direction,distance:moveDis)
            }
            
            
        }else{
            //停
            self.centerPos = self.parentView?.center
            self.delegate?.faceMove?(BLE_order.Direction.Hold_Left,distance:-1)//-1,没脸照相
        }
        
        
        
        
        
    }
    
    
    
}

extension FilteredCameraBBMetal: BBMetalCameraPhotoDelegate {
    
    
    func camera(_ camera: BBMetalCamera, didOutput texture: MTLTexture) {
        
        
        if(self.currentFilter == nil){
            DispatchQueue.global().async {
                UIImageWriteToSavedPhotosAlbum(texture.bb_image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }else{
            // In main thread
            //            let newTemp = self.filterItems
            
            
            
            //滤镜
            //            let filter = BBMetalLookupFilter(lookupTable: UIImage(named: "test_lookup")!.bb_metalTexture!)
            //            var copyFilter:BBMetalBaseFilter = BBMetalSwirlFilter(center: BBMetalPosition(x: 0.35, y: 0.55), radius: 0.25, angle: 1)
            //            self.currentFilter!.self.co
            
            let imageView = UIImageView(frame: metalView.frame)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            //            要每次新建，不然上次图片缓存一直在
            let tempFilter = FilterManager.sharedInstance.getFilterByName(name:self.currentFilter!.name)
            if(tempFilter != nil){
//                imageView.image = tempFilter!.filteredImage(with: texture.bb_image!)
                imageView.image = tempFilter!.filteredImageWithTexture(texture)//微不足道的性能
            }else{
                imageView.image = texture.bb_image!
            }
            //            self.currentFilter!.removeAllConsumers()
            //            self.currentFilter!.removeAllCompletedHandlers()
            //                    imageView.image = texture.bb_image!
            //        self..addSubview(imageView)
            //            imageView.image = texture.bb_image
            imageView.tag = 0x221
            //            self.metalView.addSubview(imageView)
            
            UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        //        print("saveImage-contextInfo\(contextInfo)")
        //        if let captureImg = self.metalView.viewWithTag(0x221){
        //            captureImg.removeFromSuperview()
        //        }
        
        var showMessage = ""
        
        if error != nil{
            
            showMessage = "保存失败"
            self.showMsg(msg: showMessage)
            
        }else{
            
            showMessage = "保存成功"
            
        }
        //        self.showMsg(msg: showMessage)
    }
    
    func camera(_ camera: BBMetalCamera, didFail error: Error) {
        // In main thread
        print("Fail taking photo. Error: \(error)")
        self.showMsg(msg: "Fail taking photo. Error: \(error)")
        
    }
}






