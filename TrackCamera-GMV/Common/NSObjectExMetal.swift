//
//  NSObjectExMetal.swift
//  tf_detection_yolo
//
//  Created by LCh on 2020/5/14.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import CoreMedia
import Metal
import AVFoundation
//import GoogleMobileVision

//import KPermission
public class NSObjectExMetal: NSObject{
    var faceDetector: GMVDetector!

    public override init() {
        super.init()
        // Initialize the face detector.
               let detectorOptions: [AnyHashable: Any] = [GMVDetectorFaceMinSize: 0.3,
                                      GMVDetectorFaceTrackingEnabled: true]
               self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: detectorOptions)
    }
    
    
    
}
