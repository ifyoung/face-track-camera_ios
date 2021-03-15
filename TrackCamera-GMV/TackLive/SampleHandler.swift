    //
    //  SampleHandler.swift
    //  TackLive
    //
    //  Created by LCh on 2020/8/17.
    //  Copyright © 2020 LC. All rights reserved.
    //
    
    import ReplayKit
    import Foundation
    
    class SampleHandler: RPBroadcastSampleHandler {
        var faceDetector: GMVDetector?
        var sendOrder_Queue = DispatchQueue.init(label: "sendOrder_Queue-live")
        
        //初始点为屏幕中心点
        public var centerPos:CGPoint!
        public var centerPosStatic:CGPoint!
        public var distance:CGFloat = 0//与中心点的距离
        
        //  移动容差,5像素点
        public var deltDistance:CGFloat = 5
        //屏幕方向
        var deviceMotion:DeviceOrientation!
        
        var JUDEG_dis:CGFloat = 9//竖屏9，横屏27
        
        
        override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
            // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
            print("ReplayKit-broadcastStarted")
            
            self.centerPos = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            deviceMotion = DeviceOrientation.init(delegate: self)
            let motionOperation = OperationQueue.init()
            motionOperation.qualityOfService = .default
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
                self.deviceMotion.startMonitor(motionOperation)
                
            }
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName.init("broadcastOrder-start" as CFString),nil, nil, true)
            
            // Initialize the face detector.
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
                let detectorOptions: [AnyHashable: Any] = [GMVDetectorFaceMinSize: 0.3,
                                                           GMVDetectorFaceTrackingEnabled: true]
                self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: detectorOptions)
                
            }
            
        }
        
        override func broadcastPaused() {
            // User has requested to pause the broadcast. Samples will stop being delivered.
            
            print("ReplayKit-broadcastPaused")
        }
        
        override func broadcastResumed() {
            // User has requested to resume the broadcast. Samples delivery will resume.
            
            print("ReplayKit-broadcastResumed")
        }
        
        override func broadcastFinished() {
            // User has requested to finish the broadcast.
            
            print("ReplayKit-broadcastFinished")
        }
        
        override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
            switch sampleBufferType {
            case RPSampleBufferType.video:
                
                print("ReplayKit-sampleBufferType")
                // Handle video sample buffer
                var deviceOri = UIDeviceOrientation.portrait
                if(deviceOrientation == TgDirection.directionPortrait){
                    deviceOri = UIDeviceOrientation.portrait
                }else if(deviceOrientation == TgDirection.directionleft){
                    deviceOri = UIDeviceOrientation.landscapeLeft
                }else if(deviceOrientation == TgDirection.directionRight){
                    deviceOri = UIDeviceOrientation.landscapeRight
                }
                let ori = GMVUtility.imageOrientation(from: deviceOri, with: AVCaptureDevice.Position.front, defaultDeviceOrientation: UIDeviceOrientation.portrait)
                let options = [GMVDetectorImageOrientation : ori.rawValue]
                if(self.faceDetector != nil){
                    guard let arrayFaceInfo = self.faceDetector!.features(in: sampleBuffer, options: options) as? [GMVFaceFeature] else {
                        //                print("No Faces 😂")
                        return
                    }
                    print("arrayFaceInfo\(String(describing: arrayFaceInfo))>>\(arrayFaceInfo.count)")
                    
                    // The video frames captured by the camera are a different size than the video preview.
                    // Calculates the scale factors and offset to properly display the features.
                    let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
                    let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, originIsAtTopLeft: false)
                    //                           let parentFrameSize = self.metalView.frame.size
                    let parentFrameSize = UIScreen.main.bounds
                    
                    // Assume AVLayerVideoGravityResizeAspect
                    let cameraRatio = clap.size.height / clap.size.width
                    let viewRatio = parentFrameSize.width / parentFrameSize.height
                    var xScale:CGFloat = 1
                    var yScale:CGFloat = 1
                    var videoBox = CGRect.zero
                    if (true) {
                        videoBox.size.width = parentFrameSize.height * clap.size.width / clap.size.height
                        videoBox.size.height = parentFrameSize.height
                        videoBox.origin.x = (parentFrameSize.width - videoBox.size.width) / 2
                        videoBox.origin.y = (videoBox.size.height - parentFrameSize.height) / 2
                        
                        xScale = videoBox.size.width / clap.size.width
                        yScale = videoBox.size.height / clap.size.height
                    } else {
                        
                        
                        
                        videoBox.size.width = parentFrameSize.width;
                        videoBox.size.height = clap.size.width * (parentFrameSize.width / clap.size.height)
                        videoBox.origin.x = (videoBox.size.width - parentFrameSize.width) / 2
                        //                videoBox.origin.x = parentFrameSize.width/2 + (parentFrameSize.width/2 - (videoBox.origin.x * xScale + videoBox.size.width))
                        videoBox.origin.y = (parentFrameSize.height - videoBox.size.height) / 2
                        
                        xScale = videoBox.size.width / clap.size.height
                        yScale = videoBox.size.height / clap.size.width
                        
                    }
                    
                    
                    
                    //                    UIView.animate(withDuration: 0.11) {
                    if(arrayFaceInfo == nil || arrayFaceInfo.count <= 0){
                        //                                   self.faceView.isHidden = true
                        //                                   self.metalView.viewWithTag(0x141)?.removeFromSuperview()
                        self.orderSendWrap()
                    }else{
                        for (index,item) in arrayFaceInfo.enumerated() {
                            
                            //                                       self.faceView.isHidden = false
                            if let faceInfo = item as? GMVFaceFeature{
                                
                                let frame = self.scaledRect(rect: faceInfo.bounds, xScale: xScale, yScale: yScale, offSet: videoBox.origin)
                                
                                print("arrayFaceInfo\(faceInfo.bounds)>>\(frame)")
                                
                                //                                    let frame = self.handleMetadataBounds(faceInfo.faceRect)
                                if(index == 0){
                                    //                                               self.faceView.frame = frame
                                    self.orderSendWrap(frame)
                                }else{
                                    //                                               let secondFace = UIView.init(frame: frame)
                                    //                                               secondFace.layer.borderWidth = 3
                                    //                                               secondFace.tag = 0x141
                                    //                                               secondFace.backgroundColor = UIColor.clear
                                    //                                               secondFace.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                                    //                                               self.metalView.addSubview(secondFace)
                                    
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    
                }
                
                
                
                
                
                
                break
            case RPSampleBufferType.audioApp:
                // Handle audio sample buffer for app audio
                break
            case RPSampleBufferType.audioMic:
                // Handle audio sample buffer for mic audio
                break
            @unknown default:
                // Handle other sample buffer types
                fatalError("Unknown type of sample buffer")
            }
        }
        func scaledRect(rect:CGRect,xScale:CGFloat,yScale:CGFloat,offSet:CGPoint) -> CGRect {
            
            //        var resultRect = CGRect.init(x: rect.origin.y * xScale, y: rect.origin.x * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
            
            var resultRect = CGRect.init(x: rect.origin.y * xScale, y: rect.origin.x * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
            if(deviceOrientation == TgDirection.directionPortrait){
                
                resultRect = CGRect.init(x: rect.origin.x * xScale, y: rect.origin.y * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
            }
            //           if(camera.position == .back){
            //               resultRect.origin.x = self.metalView.frame.midX - (resultRect.maxX - self.metalView.frame.midX)
            //           }
            resultRect = resultRect.offsetBy(dx: offSet.x, dy: offSet.y)
            
            return resultRect
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
                        self.JUDEG_dis = 9
                        self.centerPos = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                        
                        print("sendOrder_Queue-竖>>\(frame.midX)>>\(self.centerPos.x)")
                        self.distance = frame.midX - self.centerPos.x
                        
                        if(frame.midX - self.centerPos.x > self.deltDistance){//镜像？？实为左边？？
                                                    direction = BLE_order.Direction.Right
//                            direction = BLE_order.Direction.Hold_Left
                        }else if(frame.midX - self.centerPos.x < self.deltDistance){
                                                    direction = BLE_order.Direction.Hold_Left
//                            direction = BLE_order.Direction.Right
                        }
                        //                    self.centerPos = CGPoint.init(x:frame.midX , y: frame.midY)
                    }else{
                        //                        self.JUDEG_dis = 27
                        self.centerPos = CGPoint.init(x: UIScreen.main.bounds.midY, y: UIScreen.main.bounds.midX)
                        
                        print("sendOrder_Queue-横\(deviceOrientation.rawValue)>>\(frame.midX)>\(frame.midY)>>\(String(describing: self.centerPos))")
                        self.distance = frame.midX - self.centerPos.x
                        
                        if(deviceOrientation.rawValue == 4){
                            //             sendOrder_Queue-横4>>163.30040624999998>163.30040624999998>>Optional((391.1955,163.30040624999998))
                            if(frame.midX - self.centerPos.x > self.deltDistance){//右边
                                direction = BLE_order.Direction.Right
                            }else if(frame.midX - self.centerPos.x < self.deltDistance){
                                direction = BLE_order.Direction.Hold_Left
                            }
                            
                        }else if(deviceOrientation.rawValue == 3){
                            //                            sendOrder_Queue-横3>>221.266875>2x21.266875>>Optional((418.209, 221.266875))
                            if(frame.midX - self.centerPos.x > self.deltDistance){//左
                                direction = BLE_order.Direction.Hold_Left
                            }else if(frame.midX - self.centerPos.x < self.deltDistance){
                                direction = BLE_order.Direction.Right
                                
                            }
                        }
                        //                    self.centerPos = CGPoint.init(x:frame.midX , y: frame.midY)
                    }
                    
                    //过滤
                    var moveDis = abs(self.distance)
                    
                    let isInCenter = moveDis < self.JUDEG_dis //放大阙值
                    
                    if(isInCenter){//这才停
                        moveDis = 0
                    }else{
                        moveDis = 11
                        
                    }
                    
                    
                    //                    if(direction == .Hold_Left){
                    //                        direction = .Right
                    //                    }else{
                    //                        direction = .Hold_Left
                    //                    }
                    
                    print("faceMove-isInCenter-->\(moveDis)-->\(String(describing: self.centerPosStatic))-->\(String(describing: self.centerPos))")
                    
                    //                self.delegate?.faceMove?(direction,distance:moveDis)
                    if(moveDis > 0){
                        switch direction {
                            
                        case .Hold_Left:
                            print("live-facemove-左")
                            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName.init("broadcastOrder-left" as CFString),nil, nil, true)
                        case .Right:
                            print("live-facemove-右")
                            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName.init("broadcastOrder-right" as CFString),nil, nil, true)
                        }
                    }else{
                        print("live-facemove-停")
                        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName.init("broadcastOrder-hold" as CFString),nil, nil, true)
                    }
                    
                }
                
                
            }else{
                //停
                //            self.centerPos = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                print("live-facemove-停>>越界")
                
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName.init("broadcastOrder-hold" as CFString),nil, nil, true)
                
                //            self.delegate?.faceMove?(BLE_order.Direction.Hold_Left,distance:-1)//-1,没脸照相
            }
            
            
            
            
            
        }
    }
    extension SampleHandler: DeviceOrientationDelegate {
        
        func directionChange(_ direction: TgDirection) {
            print("live-directionChange\(direction)")
            deviceOrientation = direction
        }}
