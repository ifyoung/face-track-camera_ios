
//extension FilteredCameraBBMetal: AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
//import GoogleMobileVision
import MLKit

extension FilteredCameraBBMetal: BBMetalCameraVideoDelegate{
    
    func cameraVideo(_ camera: BBMetalCamera, didOutput sampleBuffer: CMSampleBuffer) {
        
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
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        //           lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: .front
        )
        
        visionImage.orientation = orientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        //                    let image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
//        let arrayFaceInfo  = detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        let arrayFaceInfo  = detectFacesOnDevice(in: visionImage, width: imageHeight, height:imageWidth )
        
        
        
        DispatchQueue.main.sync {
            
            // The video frames captured by the camera are a different size than the video preview.
                     // Calculates the scale factors and offset to properly display the features.
                     let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
                     let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, originIsAtTopLeft: false);
                     let parentFrameSize = self.metalView.frame.size;
                     
                     // Assume AVLayerVideoGravityResizeAspect
                     let cameraRatio = clap.size.height / clap.size.width;
                     let viewRatio = parentFrameSize.width / parentFrameSize.height;
                     var xScale:CGFloat = 1;
                     var yScale:CGFloat = 1;
                     var videoBox = CGRect.zero;
                     if (viewRatio > cameraRatio) {
                         videoBox.size.width = parentFrameSize.height * clap.size.width / clap.size.height;
                         videoBox.size.height = parentFrameSize.height;
                         videoBox.origin.x = (parentFrameSize.width - videoBox.size.width) / 2;
                         videoBox.origin.y = (videoBox.size.height - parentFrameSize.height) / 2;
                         
                         xScale = videoBox.size.width / clap.size.width;
                         yScale = videoBox.size.height / clap.size.height;
                     } else {
                         videoBox.size.width = parentFrameSize.width;
                         videoBox.size.height = clap.size.width * (parentFrameSize.width / clap.size.height);
                         videoBox.origin.x = (videoBox.size.width - parentFrameSize.width) / 2;
                         videoBox.origin.y = (parentFrameSize.height - videoBox.size.height) / 2;
                         
                         xScale = videoBox.size.width / clap.size.height;
                         yScale = videoBox.size.height / clap.size.width;
                         
                         
                     }
            
            
            UIView.animate(withDuration: 0.1) {
                       if(arrayFaceInfo == nil || arrayFaceInfo!.count <= 0){
                           self.faceView.isHidden = true
                           self.metalView.viewWithTag(0x141)?.removeFromSuperview()
                           self.orderSendWrap()
                       }else{
                           
                           if(arrayFaceInfo!.count < 2){
                           }
                           self.metalView.viewWithTag(0x141)?.removeFromSuperview()
                           
                           
                           for (index,item) in arrayFaceInfo!.enumerated() {
                               
                               self.faceView.isHidden = false
                               if let face = item as? Face {
                                   
                                let t = face.frame
                                let frame =  self.scaledRect(rect: face.frame, xScale: xScale, yScale: yScale, offSet: videoBox.origin)
//                                let standardizedRect = self.metalView.layer.layerRectConverted(
//                                  fromMetadataOutputRect: frame
//                                ).standardized
                                print("arrayFaceInfo\(frame)>>\(face.frame)")

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
    
    
    
    
    
    private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) -> [Face]? {
        // When performing latency tests to determine ideal detection settings, run the app in 'release'
        // mode to get accurate performance metrics.
        let options = FaceDetectorOptions()
    //    options.landmarkMode = .all
    //    options.contourMode = .all
    //    options.classificationMode = .none
        options.performanceMode = .fast
        let faceDetector = FaceDetector.faceDetector(options: options)
        var faces: [Face]
        do {
            faces = try faceDetector.results(in: image)
        } catch let error {
            print("Failed to detect faces with error: \(error.localizedDescription).")
            return nil
        }
        DispatchQueue.main.sync {
            //         self.updatePreviewOverlayView()
            //         self.removeDetectionAnnotations()
        }
        guard !faces.isEmpty else {
            print("On-Device face detector returned no results.")
            return nil
        }
        
    //    DispatchQueue.main.sync {
    //        for face in faces {
    //            let normalizedRect = CGRect(
    //                x: face.frame.origin.x / width,
    //                y: face.frame.origin.y / height,
    //                width: face.frame.size.width / width,
    //                height: face.frame.size.height / height
    //            )
    //
    //        }
    //    }
        return faces
    }

        private func handleMetadataBounds(_ bounds: CGRect)-> CGRect{
           
            let imageWidth: CGFloat = 1080
            let imageHeight: CGFloat = 1920
            let wS: CGFloat = self.metalView.bounds.width/imageWidth
            let hS: CGFloat = self.metalView.bounds.height/imageHeight

            let transPoint = self.metalView.frame.midX

            // top x, right y
            let x = camera.position == .front ?  bounds.minX : bounds.origin.x
    //        let x = bounds.origin.x
            let y = bounds.origin.y

            var frame: CGRect = .zero
            //            frame.origin.x = x * wS
            frame.size.width = bounds.width * wS
            let poX = transPoint + (transPoint - (x * wS + frame.size.width))
        frame.origin.x = camera.position == .front ? poX : x * wS
    //        frame.origin.x = x * wS
            frame.origin.y = y * hS
            frame.size.height = bounds.height * hS

            print("handleMetadataBounds\(bounds)-->\(frame)-->\(self.metalView.frame)")

            //屏幕Y轴中心对称
            //        var frameFace: CGRect = .zero
            //        frameFace.origin.x = transPoint + (transPoint - frame.maxX)
            //        frameFace.origin.y =  frame.origin.y
            //        frameFace.size = frame.size

            //        self.orderSend(frame)
            return frame


        }

    func scaledRect(rect:CGRect,xScale:CGFloat,yScale:CGFloat,offSet:CGPoint) -> CGRect {
        
        var resultRect = CGRect.init(x: rect.origin.y * xScale, y: rect.origin.x * yScale, width: rect.size.width * xScale, height: rect.size.height * yScale)
        resultRect = resultRect.offsetBy(dx: offSet.x, dy: offSet.y)
        
        return resultRect
    }
    
    
}






