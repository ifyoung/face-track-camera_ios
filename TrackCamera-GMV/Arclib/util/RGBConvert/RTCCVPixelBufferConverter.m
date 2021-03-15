//
//  RTCCVPixelBufferConverter.m
//  RTCEngine
//
//  Created by xiang on 13/08/2018.
//  Copyright © 2018 RTCEngine. All rights reserved.
//

#import "RTCCVPixelBufferConverter.h"

#import <libyuv.h>

@implementation RTCCVPixelBufferConverter

+(CVPixelBufferRef)NV12TOARGB:(CVPixelBufferRef)pixelBuffer
{
    
    NSAssert(CVPixelBufferGetPixelFormatType(pixelBuffer) ==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, @"%@: only kCVPixelFormatType_32BGRA is supported currently.",self);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    
    CVPixelBufferRef copyPixelBuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width, height, kCVPixelFormatType_32BGRA, NULL, &copyPixelBuffer);
    
    CVPixelBufferLockBaseAddress(copyPixelBuffer, 0);
    
    uint8_t *copyAddress = CVPixelBufferGetBaseAddress(copyPixelBuffer);
    
    
    uint8_t *ysrc = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
    uint8_t *uvsrc = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,1);
    
    NV12ToARGB(ysrc, width,
               uvsrc, width,
               copyAddress, width * 4,
               width, height);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CVPixelBufferUnlockBaseAddress(copyPixelBuffer, 0);
    
    return copyPixelBuffer;
}


/**
 #pragma mark - 将32BGRA格式视频buffer转为y_uv格式NSData
 +(MHVideoData)convertBGRABufferToY_UVData:(CVPixelBufferRef)videoBuffer
 {
 MHVideoData videoData = {nil,0,0};
 OSType pixelFormatType = CVPixelBufferGetPixelFormatType(videoBuffer);
 if (pixelFormatType == kCVPixelFormatType_32BGRA) {
 int width = (int)CVPixelBufferGetWidth(videoBuffer);
 int height  = (int)CVPixelBufferGetHeight(videoBuffer);
 //宽*高
 int w_x_h = width * height;
 //yuv数据长度 = (宽 * 高) * 3 / 2
 int yuv_len = w_x_h * 3 / 2;
 //yuv数据
 uint8_t *yuv_bytes = malloc(yuv_len);
 
 //ARGBToNV12这个函数是libyuv这个第三方库提供的一个将bgra图片转为yuv420格式的一个函数。
 //libyuv是google提供的高性能的图片转码操作。支持大量关于图片的各种高效操作，是视频推流不可缺少的重要组件，你值得拥有。
 CVPixelBufferLockBaseAddress(videoBuffer, 0);
 uint8_t *srcAddress = CVPixelBufferGetBaseAddress(videoBuffer);
 ARGBToNV12(srcAddress, width * 4, yuv_bytes, width, yuv_bytes + w_x_h, width, width, height);
 CVPixelBufferUnlockBaseAddress(videoBuffer, 0);
 
 NSData *yuvData = [NSData dataWithBytesNoCopy:yuv_bytes length:yuv_len];
 free(yuv_bytes);
 yuv_bytes = nil;
 
 videoData.videoData = yuvData;
 videoData.width = (int)width;
 videoData.height = (int)height;
 }else{
 NSLog(@"buffer转换失败，只支持32BGRA格式视频帧");
 }
 return videoData;
 }
 */





+(CVPixelBufferRef)ARGBTONV12:(uint8_t*)srcAddress width:(int)width height:(int)height
{
    int half_width = (width + 1) / 2;
    int half_height = (height + 1) / 2;

//    const int y_size = width * height;
//    const int uv_size = half_width * half_height * 2 ;
//    const size_t total_size = y_size + uv_size;


    CVPixelBufferRef pixelBuffer = NULL;

    CVPixelBufferCreate(kCFAllocatorDefault, width , height,
                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                        NULL, &pixelBuffer);

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *yplan = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
    uint8_t *uvplan = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,1);
    ARGBToNV12(srcAddress, width * 4,
               yplan, width,
               uvplan,  width,
               width, height);

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return pixelBuffer;
}

//+(CVPixelBufferRef)ARGBTONV12:(uint8_t*)srcAddress width:(int)width height:(int)height
//{
//    //宽*高
//    int w_x_h = width * height;
//    //yuv数据长度 = (宽 * 高) * 3 / 2
//    int yuv_len = w_x_h * 3 / 2;
//    //yuv数据
//    uint8_t *yuv_bytes = malloc(yuv_len);
//
//
//    CVPixelBufferRef pixelBuffer = NULL;
//
//    CVPixelBufferCreate(kCFAllocatorDefault, width , height,
//                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
//                        NULL, &pixelBuffer);
//        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    ARGBToNV12(srcAddress, width * 4, yuv_bytes, width, yuv_bytes + w_x_h, width, width, height);
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//
//    free(yuv_bytes);
//    yuv_bytes = nil;
//
//    return pixelBuffer;
//}

@end
