

import Foundation
import UIKit
import CoreVideo
import CoreGraphics
import AVFoundation

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        
        if hexString.hasPrefix("#") {
//            let start = hexString.index(hexString.startIndex, offsetBy: 1)
//            let hexColor = hexString.substring(from: start)
            
            let hexColor = hexString.substring(fromIndex: 1)

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255//16~24
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255//8~16
                    b = CGFloat(hexNumber & 0x0000ff) / 255// ~8
                    //a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
}
extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: 1.0)
        }else{
            return nil
        }
    }
}

extension CGFloat{
    func fixColor()->CGFloat{
        return  CGFloat(Global.adjustColor(c: Int(self)))
    }
}
extension Int{
    func fixColor()->CGFloat{
        return  CGFloat(Global.adjustColor(c: Int(self)))
    }
}

//
extension CGImage{
//     func pixelBuffer(forImage image:CGImage) -> CVPixelBuffer?{
//     typealias CVImageBuffer = CVBuffer
    func getPixelBuffer(osType:OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer?{
//           CVBufferRef
           let frameSize = CGSize(width: self.width, height: self.height)
           
           var pixelBuffer:CVPixelBuffer? = nil
           let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), osType , nil, &pixelBuffer)
           
           if status != kCVReturnSuccess {
               return nil
               
           }
           
           CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
           /*
            Lock the base address of the pixel buffer
            We must call the CVPixelBufferLockBaseAddress(_:_:) function before accessing pixel data with the CPU, and call the CVPixelBufferUnlockBaseAddress(_:_:) function afterward. If you include the readOnly value in the lockFlags parameter when locking the buffer, you must also include it when unlocking the buffer.
            */
           let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
           /*
            return the base address of the pixel buffer
            retrieving the base address for a pixel buffer requires that the buffer base address be locked using the CVPixelBufferLockBaseAddress(_:_:) function.
            */
           let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
           let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
           let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
           /*
            Core Graphic is also known as Quartz2D.
            We can know the API is based on Core Graphic framwork, so the data types and the routines that operate on them use CGprefix
            */
           
          
           context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
           CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
           
           return pixelBuffer
           
       }
    
    
      func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                       colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo,
                       orientation: CGImagePropertyOrientation) -> CVPixelBuffer? {
          
          // TODO: If the orientation is not .up, then rotate the CGImage.
          // See also: https://stackoverflow.com/a/40438893/
          assert(orientation == .up)
          
          var maybePixelBuffer: CVPixelBuffer?
          let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                       kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
          let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                           width,
                                           height,
                                           pixelFormatType,
                                           attrs as CFDictionary,
                                           &maybePixelBuffer)
          
          guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
              return nil
          }
          
          let flags = CVPixelBufferLockFlags(rawValue: 0)
          guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
              return nil
          }
          defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
          
          guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                        width: width,
                                        height: height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                        space: colorSpace,
                                        bitmapInfo: alphaInfo.rawValue)
              else {
                  return nil
          }
          
          context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
          return pixelBuffer
      }
    func pixelBufferEx(pixelFormatType: OSType,
                          colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo,
                          orientation: CGImagePropertyOrientation) -> CVPixelBuffer? {
             
             // TODO: If the orientation is not .up, then rotate the CGImage.
             // See also: https://stackoverflow.com/a/40438893/
             assert(orientation == .up)
             
             var maybePixelBuffer: CVPixelBuffer?
             let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
             let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              self.width,
                                              self.height,
                                              pixelFormatType,
                                              attrs as CFDictionary,
                                              &maybePixelBuffer)
             
             guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
                 return nil
             }
             
             let flags = CVPixelBufferLockFlags(rawValue: 0)
             guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
                 return nil
             }
             defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
             
             guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                           width: self.width,
                                           height: self.height,
                                           bitsPerComponent: 8,
                                           bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                           space: colorSpace,
                                           bitmapInfo: alphaInfo.rawValue)
                 else {
                     return nil
             }
             
        context.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
             return pixelBuffer
         }
    
    
    
}

extension CMSampleBuffer {

    // Converts a CMSampleBuffer to a UIImage
    //
    // Return: UIImage from CMSampleBuffer
    func toUIImage() -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: 1, orientation: .right)
            }
        }
        return nil
    }

    // Converts a CMSampleBuffer to a CGImage
    //
    // Return: CGImage from CMSampleBuffer
    func toCGImage() -> CGImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(self) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

            if let image = context.createCGImage(ciImage, from: imageRect) {
                return image
            }

        }
        return nil
    }

    // Converts a CMSampleBuffer to a CIImage
    //
    // Return: CIImage from CMSampleBuffer
    func toCIImage() -> CIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(self) {
            return CIImage(cvPixelBuffer: pixelBuffer)
        } else {
            return nil
        }
    }

}

extension UIView{
//    iOS清除UIDatePicker和UIPickerView中间Row上面的分割线
//
//————————————————
//版权声明：本文为CSDN博主「维庆」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
//原文链接：https://blog.csdn.net/IOS_dashen/article/details/50214407
    //取出高度小于5的线,0.5
    func clearSeparatorWithView(){
        for subView in self.subviews {
            if(subView.frame.size.height < 2){
                subView.isHidden = true
            }
        }
    }
    
}

/** @abstract UIWindow hierarchy category.  */
/**获取窗体视图控制器相关拓展*/
public extension UIWindow {

    /** @return Returns the current Top Most ViewController in hierarchy.   */
     func topMostController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostController.    */
    func currentViewController()->UIViewController? {
        
        var currentViewController = topMostController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }

        return currentViewController
    }
    
   
}

