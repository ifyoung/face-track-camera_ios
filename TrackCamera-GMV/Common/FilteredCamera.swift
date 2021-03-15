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

@objc protocol FilteredCameraDelegate {
    @objc optional  func filteredCamera(didUpdate image: CIImage)
    @objc optional  func videoCapture(_ capture: FilteredCamera, didCaptureVideoTexture texture: MTLTexture?, timestamp: CMTime)
    //    mlmnodel
    @objc optional func videoCapture(_ capture: FilteredCamera, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
    
    func metaCapture(_ capture: FilteredCamera,faceBoxes:NSMutableArray, didOutputMetadataObjects: [AVMetadataObject])
}


class FilteredCamera: NSObjectExMetal {
    
    //static let sharedInstance = FilteredCamera()
    
    var delegate: FilteredCameraDelegate?
    
    private var captureSession = AVCaptureSession()
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice?
    
    //    private var photoOutput: AVCapturePhotoOutput?
    //    private var photoOutput: AVCaptureOutput?
    public var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let context = CIContext()
    
    // MARK: GLOBAL
    var av_detection_Queue = DispatchQueue.init(label: "av_detection_Queue")
    var camera_output_Queue = DispatchQueue.init(label: "camera_output_Queue")
    
    let semaphore = DispatchSemaphore(value: 1)
    //    public let videoOutput = AVCaptureVideoDataOutput()
    public let metaOutput = AVCaptureMetadataOutput()
    private var faceMetaData = [AVMetadataObject]()
    
    var facesViewArr:NSMutableArray!
    
    
    var parentView:UIView?
    
    init(externalView: UIView? = nil,finish:(()->Void)?) {
        //        self.device = device
        super.init()
        parentView = externalView
        facesViewArr = NSMutableArray.init(capacity: 0)
        captureSession.beginConfiguration()
        self.setupCaptureSession()
        self.setupDevice()
        self.setupPreviewLayer(view: externalView)
        self.setCameraConfig()
        self.setupMetaOutputDelegate()
        
        captureSession.commitConfiguration()
        
        //        self.setupMetaOutputDelegate()
        
        
        self.start()
        //        isCameraSetup = true
        finish!()
        //        self.startRunningCaptureSession()//神经网络初始化完成才开始录像识别,防止闪屏改为先开镜，深度学习转后台
    }
    
    // MARK: PRIVATE
    private func setupCaptureSession() {
        // should support anything up to 1920x1080 res, incl. 240fps @ 720p
        //        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
    }
    
    
    private func setupDevice() {
        //        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        //        let devices = deviceDiscoverySession.devices
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        //        currentCamera = frontCamera
    }
    
    public func setCameraConfig(isClickSwitch:Bool = false) {
        if(!isClickSwitch){
            self.currentCamera = backCamera
        }else{
            for faceView in self.facesViewArr {
                if let v = faceView as? UIView{
                    v.removeFromSuperview()
                }
            }
            self.currentCamera = self.currentCamera == backCamera ? frontCamera : backCamera
            //            (self.parentView?.layer.sublayers![0] as! CALayer).add(CAAnimation, forKey: String?)
        }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.currentCamera!)
            
            //清空原来的
            if let inputs = self.captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            if self.captureSession.canAddInput(captureDeviceInput) {
                self.captureSession.addInput(captureDeviceInput)
            }
            
            //                if #available(iOS 10.0, *) {
            //                 self.photoOutput = AVCapturePhotoOutput.init()
            //                    (self.photoOutput as! AVCapturePhotoOutput ).setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
            //                } else {
            //                    // Fallback on earlier versions
            //                }
            
            //防止初次识别不能初始化
            //                self.setupMetaOutputDelegate()
            
        } catch {
            print("activateCamera\(error)")
        }
        
        
        
    }
    
    private func setupPreviewLayer(view: UIView?) {
        guard let view = view else { fatalError("No view for camera!") }
        
        let pathLayer = CAShapeLayer()
        
        pathLayer.path = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height), cornerRadius: 1).cgPath
        pathLayer.strokeColor = nil
        pathLayer.fillColor = UIColor.clear.cgColor
        view.layer.insertSublayer(pathLayer, at: 0)
//        view.layer.addSublayer(pathLayer)
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        cameraPreviewLayer?.connection?.videoOrientation = transformOrientation(orientation: UIDevice.current.orientation)
        
//        cameraPreviewLayer?.frame = CGRect(x:0, y:0, width:self.parentView!.frame.width, height:1)
        cameraPreviewLayer?.frame = CGRect(x:0, y:self.parentView!.frame.height, width:self.parentView!.frame.width, height:50)
//        cameraPreviewLayer?.frame = view.bounds
//        cameraPreviewLayer?.frame = CGRect.zero
        //        view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)//不会触发动画
        //        view.layer.addSublayer(self.cameraPreviewLayer!)
        shapePathAnim(layer: (cameraPreviewLayer)!)
        pathLayer.addSublayer(self.cameraPreviewLayer!)

        
    }
    private func shapePathAnim(layer:CALayer){
        //Create tween
//              let tween:Tween = Tween(target:layer,//Target
//                  duration:1.0,//One second
//                  ease:Ease.inOutCubic,
//                  keys:[\CALayer.alpha:1.0,
//                        \UIView.frame:CGRect(x:20.0, y:20.0, width:280.0, height:280.0),
//                        //This property is an optional.
//                        \UIView.backgroundColor!:UIColor.red
//                  ])
                  let tween:Tween = Tween(target:layer,//Target
                    duration:0.5,//One second
                      ease:Ease.outInBounce,
                      keys:[
                            \CALayer.fillMode:CAMediaTimingFillMode.forwards,
                            \CALayer.frame:CGRect(x:0, y:0, width:self.parentView!.frame.width, height:self.parentView!.frame.height)
                            //This property is an optional.
//                        \CALayer.isRemovedOnCompletion:false,
                        
                      ])

              //Add tween
              tween.onComplete = {
                  print("Tween complete")
              }
              
              tween.play()
      }
    
    
    private func setupMetaOutputDelegate() {
        
        if self.captureSession.canAddOutput(metaOutput) {
            //            metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //先加到captureSession
            self.captureSession.addOutput(metaOutput)
            //            self.setupPreviewLayer(view: parentView)
            metaOutput.setMetadataObjectsDelegate(self, queue: .main)
            
            if metaOutput.availableMetadataObjectTypes.contains(.face) {
                metaOutput.metadataObjectTypes = [.face]
            }
            //            metaOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            //        metaOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            if(cameraPreviewLayer != nil){
                //这个会导致代理方法不执行？？
                //                metaOutput.rectOfInterest = cameraPreviewLayer!.bounds
            }
            metaOutput.connection(with: AVMediaType.video)?.videoOrientation = transformOrientation(orientation: UIDevice.current.orientation)
        }
        setupVideoDataOutputDelegate()
    }
    private func setupVideoDataOutputDelegate() {
        // let videoOutput = AVCaptureVideoDataOutput()
        //videoOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.main)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: camera_output_Queue)
        if self.captureSession.canAddOutput(videoOutput) {
            self.captureSession.addOutput(videoOutput)
        }
    }
    
    public func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
            backCamera?.unlockForConfiguration()
            print("captureSession-startAA")
        }
    }
    
    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func transformOrientation(orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeRight:       return .landscapeLeft
        case .landscapeLeft:        return .landscapeRight
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    var captureCount : Int = 0
    var lastTimestamp = CMTime()
    public var fps = -1
    
}

extension FilteredCamera: AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if(self.cameraPreviewLayer == nil){
            return
        }
        
        semaphore.wait()
        for faceView in self.facesViewArr {
            if let v = faceView as? UIView{
                v.removeFromSuperview()
            }
        }
        facesViewArr.removeAllObjects()
        for faceOb in metadataObjects{
            let faceData = self.cameraPreviewLayer?.transformedMetadataObject(for: faceOb)
            let r = faceData?.bounds
            let faceBox = UIView.init(frame: r!)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.blue.cgColor
            faceBox.backgroundColor = UIColor.clear
            faceMetaData.append(faceData!)
            facesViewArr.add(faceBox)
            
            if let pv = self.parentView{
                //                pv.addSubview(faceBox)
                pv.layer.addSublayer(faceBox.layer)
            }
            
        }
        delegate?.metaCapture(self, faceBoxes: facesViewArr, didOutputMetadataObjects:faceMetaData)
        semaphore.signal()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let cameraImage = CIImage(cvImageBuffer: pixelBuffer)
            self.delegate?.filteredCamera!(didUpdate: cameraImage)
        } else {
            print("No pixelBuffer")
        }
        
    }
    
    
}
