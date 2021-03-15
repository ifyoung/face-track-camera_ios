//
//  BBMetalCameraEx.swift
//  LC
//
//  Created by Mac on 06.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import CoreVideo
import AVFoundation

public enum CameraDevice {
    case front, back
}
public enum CameraFlashMode: Int {
    case off, on, auto
}
//public enum CameraOutputMode {
//    case stillImage, videoWithMic, videoOnly
//}
public enum CameraOutputMode {
    case image, video
}
//private extension AVCaptureDevice {
//    static var videoDevices: [AVCaptureDevice] {
//        return AVCaptureDevice.devices(for: AVMediaType.video)
//    }
//}

class BBMetalCameraEx : BBMetalCamera{
    
    fileprivate var zoomScale = CGFloat(1.0)
    fileprivate var beginZoomScale = CGFloat(1.0)
    fileprivate var maxZoomScale = CGFloat(1.0)
    //    let settings = AVCapturePhotoSettings()
    
    //    fileprivate var cameraIsSetup = false
    
    fileprivate var cameraOutputMode:CameraOutputMode = .image
    
    open var flashMode: CameraFlashMode = .off {
        didSet {
            if self.cameraIsSetup && flashMode != oldValue {
                _updateIlluminationMode(flashMode)
            }
        }
    }
    
    /// Property to change camera output.
    //       open var cameraOutputMode: CameraOutputMode = .stillImage {
    //           didSet {
    //               if cameraIsSetup {
    //                   if cameraOutputMode != oldValue {
    //                       _setupOutputMode(cameraOutputMode, oldCameraOutputMode: oldValue)
    //                   }
    ////                   _setupMaxZoomScale()
    ////                   _zoom(0)
    //               }
    //           }
    //       }
    
    
    fileprivate func _updateTorch(_ mode: CameraFlashMode) {
        self.session?.beginConfiguration()
        defer { self.session?.commitConfiguration() }
        //        for captureDevice in AVCaptureDevice.videoDevices {
        guard let avTorchMode = AVCaptureDevice.TorchMode(rawValue: mode.rawValue) else { return }
        //            if captureDevice.isTorchModeSupported(avTorchMode), cameraDevice == .back {
        if self.camera.isTorchModeSupported(avTorchMode), self.position == .back {
            do {
                try self.camera.lockForConfiguration()
                self.camera.torchMode = avTorchMode
                self.camera.unlockForConfiguration()
            } catch {
                return
            }
        }
        
    }
    
    fileprivate func _updateFlash(_ flashMode: CameraFlashMode) {
        self.session?.beginConfiguration()
        defer { self.session?.commitConfiguration() }
        
        
        //10以上无效
        //        guard let avFlashMode = AVCaptureDevice.FlashMode(rawValue: flashMode.rawValue) else { return }
        //        if self.camera.isFlashModeSupported(avFlashMode) {
        //            do {
        //                try self.camera.lockForConfiguration()
        //                self.camera.flashMode = avFlashMode
        //                self.camera.unlockForConfiguration()
        //            } catch {
        //                return
        //            }
        //        }
        
        //        for captureDevice in AVCaptureDevice.videoDevices {
        //            guard let avFlashMode = AVCaptureDevice.FlashMode(rawValue: flashMode.rawValue) else { continue }
        //            if captureDevice.isFlashModeSupported(avFlashMode) {
        //                do {
        //                    try captureDevice.lockForConfiguration()
        //                    captureDevice.flashMode = avFlashMode
        //                    captureDevice.unlockForConfiguration()
        //                } catch {
        //                    return
        //                }
        //            }
        //        }
    }
    
    
    public  func takePhotoWithFlash(){
        self.takePhoto(flashState: AVCaptureDevice.FlashMode.init(rawValue: flashMode.rawValue)!)
    }
    
    
  //自动闪光灯luoji
//    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);

//    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
//        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
//
//        if (brightnessValue <= -2 && !_isAutoOpen) {
//            _isAutoOpen = YES;
//            [self.torchBtn setSelected:YES];
//            [self turnTorchOn:YES];
//        }
//    ————————————————
//    版权声明：本文为CSDN博主「岑志军」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
//    原文链接：https://blog.csdn.net/u013094208/article/details/75649458
    
    
    
    public  func _updateIlluminationMode(_ mode: CameraFlashMode) {
        if cameraOutputMode != .image {
            _updateTorch(mode)
        } else {
            if(self.camera.isTorchActive){//从视频切换到相机
                _updateTorch(CameraFlashMode.off)
            }
            _updateFlash(mode)
        }
    }
    
    open func changeFlashMode(cameraOutputMode:CameraOutputMode) -> CameraFlashMode {
        self.cameraOutputMode = cameraOutputMode
        guard let newFlashMode = CameraFlashMode(rawValue: (flashMode.rawValue + 1) % 3) else { return flashMode }
        flashMode = newFlashMode
        return flashMode
    }
    
    
    
    
}

extension BBMetalCamera{
     open func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
                //method 1 - specific
    //            let d1 = AVCaptureDevice.default(for: .video)
    //            let d2 = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front)
    //
                
                //method 2 - sets of devices
                var deviceTypes = [AVCaptureDevice.DeviceType.builtInDualCamera,
                                   .builtInMicrophone,
                                   .builtInTelephotoCamera,
                                   .builtInWideAngleCamera]
                
                if #available(iOS 11.1, *) {
                    deviceTypes.append(AVCaptureDevice.DeviceType.builtInTrueDepthCamera)
                }
                
                let s = AVCaptureDevice.DiscoverySession(
                    deviceTypes: deviceTypes,
                    mediaType: AVMediaType.video,
                    position: AVCaptureDevice.Position.unspecified)
                for device in s.devices {
                    if device.position == position {
                        return device
                    } else {
                        return nil
                    }
                }
                return nil
            }
    //    ————————————————
    //    版权声明：本文为CSDN博主「muerbingsha」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
    //    原文链接：https://blog.csdn.net/muerbingsha/article/details/80460088
        
}



extension BBMetalCameraEx{
    
//    fileprivate struct AssociatedObjectKeys {//key值唯一，可自定义
//        static var filterVar = "filterVar"
//    }
//    fileprivate var filterTypes: [FilterType]? {
//        set {
//            if let newValue = newValue {
//                // Computed properties get stored as associated objects
//                objc_setAssociatedObject(self, &AssociatedObjectKeys.filterVar, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//            }
//        }
//        get {
//            let filterVarInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.filterVar) as? [FilterType]
//            return filterVarInstance
//        }
//    }
    
//   public func getFilters(types:[FilterType]? = nil)->[BBMetalBaseFilter?]{
//     return FilterManager.sharedInstance.getFilterList(filters: types)
//    }
    
    
}




