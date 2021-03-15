
//extension FilteredCameraBBMetal: AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
//import GoogleMobileVision

extension FilteredCameraBBMetal: BBMetalCameraVideoDelegate{
    
    func cameraVideo(_ camera: BBMetalCamera, didOutput sampleBuffer: CMSampleBuffer) {
        if(isInBackGround){
            return
        }
        if(self.setAutoFlashVar != nil){
            let metadataDict =  CMCopyDictionaryOfAttachments(allocator:nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
            let metadata = NSMutableDictionary.init(dictionary: metadataDict!)
            //        CFRelease(metadataDict)
            let exifMetadata = metadata.object(forKey: kCGImagePropertyExifDictionary) as! NSDictionary
            let brightnessValue = exifMetadata.object(forKey: kCGImagePropertyExifBrightnessValue) as! Double
            if(brightnessValue <= -2){
                self.setAutoFlashVar!(true)
            }
            self.setAutoFlashVar = nil//回调完成后重置??
            //        isNeedFlash = brightnessValue <= -2
            //        print("isNeedFlash\(isNeedFlash)")
        }
        
        var deviceOri = UIDeviceOrientation.portrait
        if(deviceOrientation == TgDirection.directionPortrait){
            deviceOri = UIDeviceOrientation.portrait
        }else if(deviceOrientation == TgDirection.directionleft){
            deviceOri = UIDeviceOrientation.landscapeLeft
        }else if(deviceOrientation == TgDirection.directionRight){
            deviceOri = UIDeviceOrientation.landscapeRight
        }
        
        //                    let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
        let ori = GMVUtility.imageOrientation(from: deviceOri, with: camera.position, defaultDeviceOrientation: UIDeviceOrientation.portrait)
        let options = [GMVDetectorImageOrientation : ori.rawValue]
        //        let t = faceDetector
        //        let arrayFaceInfo = self.faceDetector.features(in: sampleBuffer, options: op)
        //        guard let arrayFaceInfo = self.faceDetector.features(in: sampleBuffer, options: options) as? [GMVFaceFeature] else {
        //                   print("No Faces 😂")
        //                   return
        //               }
        guard let arrayFaceInfo = self.faceDetector.features(in: sampleBuffer, options: options) as? [GMVFaceFeature] else {
            print("No Faces 😂")
            return
        }
        //            let arrayFaceInfo = faceDetector?.features(in: image!, options: op)
        print("arrayFaceInfo\(String(describing: arrayFaceInfo))")
        DispatchQueue.main.async {
            
            // The video frames captured by the camera are a different size than the video preview.
            // Calculates the scale factors and offset to properly display the features.
            let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
            let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, originIsAtTopLeft: false)
            let parentFrameSize = self.metalView.frame.size
            
            // Assume AVLayerVideoGravityResizeAspect
            let cameraRatio = clap.size.height / clap.size.width
            let viewRatio = parentFrameSize.width / parentFrameSize.height
            var xScale:CGFloat = 1
            var yScale:CGFloat = 1
            var videoBox = CGRect.zero
            if (false) {
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
            
            
            
            UIView.animate(withDuration: 0.11) {
                if(arrayFaceInfo == nil || arrayFaceInfo.count <= 0){
                    self.faceView.isHidden = true
                    self.metalView.viewWithTag(0x141)?.removeFromSuperview()
                    self.orderSendWrap()
                }else{
                    
                    if(arrayFaceInfo.count < 2){
                    }
                    self.metalView.viewWithTag(0x141)?.removeFromSuperview()
                    
                    
                    for (index,item) in arrayFaceInfo.enumerated() {
                        
                        self.faceView.isHidden = false
                        if let faceInfo = item as? GMVFaceFeature{
                            
                            print("arrayFaceInfo\(faceInfo)")
                            let frame = self.scaledRect(rect: faceInfo.bounds, xScale: xScale, yScale: yScale, offSet: videoBox.origin)
                           
                            print("arrayFaceInfo->Ori\(faceInfo.bounds)")
                            print("arrayFaceInfo->Trans\(frame)")

                            //                                    let frame = self.handleMetadataBounds(faceInfo.faceRect)
                            if(index == 0){
                                self.faceView.frame = frame
                                self.orderSendWrap(frame)
                            }else{
                                let secondFace = UIView.init(frame: frame)
                                secondFace.layer.borderWidth = 3
                                secondFace.tag = 0x141
                                secondFace.backgroundColor = UIColor.clear
                                secondFace.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                                self.metalView.addSubview(secondFace)
                                
                                
                            }
                            
                        }
                        
                    }
                }
            }
            
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
    //    private func handleMetadataBounds(_ faceRect: MRECT)-> CGRect{
    //        let bounds = CGRect.init(x: CGFloat(faceRect.left), y: CGFloat(faceRect.top), width: abs(CGFloat(faceRect.left) - CGFloat(faceRect.right)), height: abs(CGFloat(faceRect.bottom) - CGFloat(faceRect.top)))
    //        let imageWidth: CGFloat = 1080
    //        let imageHeight: CGFloat = 1920
    //        let wS: CGFloat = self.metalView.bounds.width/imageWidth
    //        let hS: CGFloat = self.metalView.bounds.height/imageHeight
    //
    //        let transPoint = self.metalView.frame.midX
    //
    //        // top x, right y
    //        let x = camera.position == .front ?  bounds.minX : bounds.origin.x
    ////        let x = bounds.origin.x
    //        let y = bounds.origin.y
    //
    //        var frame: CGRect = .zero
    //        //            frame.origin.x = x * wS
    //        frame.size.width = bounds.width * wS
    //        let poX = transPoint + (transPoint - (x * wS + frame.size.width))
    //    frame.origin.x = camera.position == .front ? poX : x * wS
    ////        frame.origin.x = x * wS
    //        frame.origin.y = y * hS
    //        frame.size.height = bounds.height * hS
    //
    //        print("handleMetadataBounds\(bounds)-->\(frame)-->\(self.metalView.frame)")
    //
    //        //屏幕Y轴中心对称
    //        //        var frameFace: CGRect = .zero
    //        //        frameFace.origin.x = transPoint + (transPoint - frame.maxX)
    //        //        frameFace.origin.y =  frame.origin.y
    //        //        frameFace.size = frame.size
    //
    //        //        self.orderSend(frame)
    //        return frame
    //
    //
    //    }
    
    func scaledRect(rect:CGRect,xScale:CGFloat,yScale:CGFloat,offSet:CGPoint) -> CGRect {
        
        //        var resultRect = CGRect.init(x: rect.origin.y * xScale, y: rect.origin.x * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        
        var resultRect = CGRect.init(x: rect.origin.y * xScale, y: rect.origin.x * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        if(camera.position == .back){
            resultRect.origin.x = self.metalView.frame.midX - (resultRect.maxX - self.metalView.frame.midX)
        }
        resultRect = resultRect.offsetBy(dx: offSet.x, dy: offSet.y)
        
        return resultRect
    }
    
    
    
}
