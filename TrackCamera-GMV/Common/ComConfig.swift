//
//  ComConfig.swift
//  tf_detection_yolo
//
//  Created by LCh on 2020/5/14.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import AudioToolbox
import UIKit




//虹软激活状态
var ARC_active = false
var isARCProgress_Init = false//线程是否初始化成功

//var faceDetector:GMVDetector?

let fpsCounter = FPSCounter()

var AppDelegateMain:AppDelegate?

var isInBackGround = false


var ASF_APPID = "8rpGZPJoGMY4VM62aRpYYMZDD7Gi8x9iVvcwN4roecyJ"
var ASF_SDKKEY = "F2oMFXpFkb9pbKR5nFpgTpvnyVjVDWqEA8zXkUTXHfuX"

//略过最后一个小数点
let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

let GlobalToast = ToastView()
let GetAPPKeyURL = "http://snp-us.top/ydcp/sp/findHRAppInfo"









//let BLEServiceUUID = "FFB0"


let KEY_FIRST = "isFirstIN"


let EMPTYVARCHAR=""
//var filterItemsPhoto = [BBMetalBaseFilter?]()
var filterItemsVideo = [BBMetalBaseFilter?]()
var filterItemsStatic = [BBMetalBaseFilter?]()

let Theme_COLOR:UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)


var currentPeripheral:CBPeripheral?

var DeviceCorrectMac = EMPTYVARCHAR

class Global: NSObject {
    
    //获取openUUID...唯一
    
    
    class func vibrat(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    class func peekVibrat(){
        //        AudioServicesPlaySystemSound(1104)
        tapticEngine()
    }
    
    class func tapticEngine(){
        //        AudioServicesPlaySystemSound(1104)
        //        AudioServicesPlaySystemSound(1519)
        //peek-1519;pop-1520;error-1521
        AudioServicesPlaySystemSound(SystemSoundID(1519))
        
        //受系统触感反馈控制
        //        if #available(iOS 10.0, *) {
        //            impact = UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.light)
        //            impact?.impactOccurred()
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
    }
    
    class func saveBleUUID(_ uuid:String){
        let defaults=UserDefaults.standard
        defaults.set(uuid, forKey: "bleuuid")
        defaults.synchronize()
    }
    
    class func getBleUUID()-> String {
        let defaults=UserDefaults.standard
        let uuid = defaults.object(forKey: "bleuuid")
        if(uuid != nil){
            return uuid! as! String
        }else{
            return EMPTYVARCHAR
        }
    }
    //333333以下判为黑色
    class func matchBlack(str:String)->Bool{
        // 1. 创建正则表达式规则
        //        let pattern = "[0-3]{6}"
        //炫彩模式会s涉及到4
        let pattern = "[0-4]{6}"
        
        // 2. 创建正则表达式对象
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        // 3. 匹配字符串中内容
        let results =  regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
        
        //        print("颜色判断初始\(results)")
        if(results.count>0){
            
            return true
        }
        
        return false
    }
    
    
    class func saveBleName(_ name:String,nameKey:String){//别名与固件版本,设备号,用户标示，地址
        let myName=UserDefaults.standard
        myName.set(name, forKey: nameKey)
        myName.synchronize()
    }
    
    class func getBleName(nameKey:String)-> String {
        let myName=UserDefaults.standard
        let myNameGet = myName.object(forKey: nameKey)
        if(myNameGet != nil){
            return myNameGet! as! String
        }else{
            return EMPTYVARCHAR
        }
    }
    
    class func saveLocal(_ name:String,nameKey:String){//存储激活状态或其他持久变量
        let myLocalData=UserDefaults.standard
        myLocalData.set(name, forKey: nameKey)
        myLocalData.synchronize()
    }
    
    class func getLocalData(nameKey:String)-> String {
        let myLocalData=UserDefaults.standard
        let myLocalDataGet = myLocalData.object(forKey: nameKey)
        if(myLocalDataGet != nil){
            return myLocalDataGet! as! String
        }else{
            return EMPTYVARCHAR
        }
    }
    
    
    class func isFirst()->Bool{
        let defaults=UserDefaults.standard
        let first = defaults.object(forKey: KEY_FIRST)
        if(first != nil){
            if((first as! String) == "first"){
                defaults.set("noAds", forKey: KEY_FIRST)//第一次进入不显示广告
                defaults.synchronize()
                
            }
            return false
        }else{
            
            defaults.set("first", forKey: KEY_FIRST)
            defaults.synchronize()
            return true
        }
    }
    
    class func isShowAds()->Bool {
        let defaults=UserDefaults.standard
        let firstAds = defaults.object(forKey: KEY_FIRST)
        
        if((firstAds as! String) == "noAds"){
            
            return true
        }
        
        return false
    }
    
    
    class func isIpad()->Bool{
        //        if( UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
        if( UIDevice.current.model.lowercased().contains("ipad")){
            
            return true
        }else {
            return false
        }
    }
    
    //@"iPhone6,1" : @"iPhone 5s",
    //            @"iPhone6,2" : @"iPhone 5s",
    //            @"iPhone7,2" : @"iPhone 6",
    //            @"iPhone7,1" : @"iPhone 6 Plus",
    //            @"iPhone8,1" : @"iPhone 6s",
    //            @"iPhone8,2" : @"iPhone 6s Plus",
    //            @"iPhone8,4" : @"iPhone SE (1st generation)",
    //    ————————————————
    //    版权声明：本文为CSDN博主「叫我伯爵大人」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
    //    原文链接：https://blog.csdn.net/justbeme/article/details/106712072
    class func isOnlySurport720P()->Bool{//iphone 7以下前置不支持1080p
        //        if( UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad){
        if(UIDevice.current.model.contains("iPhone6") ||
            UIDevice.current.model.contains("iPhone7") ||
            UIDevice.current.model.contains("iPhone8")){
            
            return true
        }else {
            return false
        }
    }
    
    class func txtSize(txt:String,fontSize:CGFloat)->CGSize{
        
        let sizeTxt = (txt).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        
        return sizeTxt
    }
    
    class func isIphoneX()->Bool{
        print("品目狂傲\(UIScreen.main.nativeBounds.height)--宽-\(UIScreen.main.nativeBounds.width)---\(UIScreen.main.bounds.height)")
        
        if( UIScreen.main.bounds.height >= 812){
            
            return true
        }else {
            return false
        }
    }
    
    
    
    //RGB灯颜色校准
    class func adjustColor(c:Int)-> Int{
        var tempC = c
        //        if(0<c && c<=127){
        //
        //          tempC = abs(c - 15 * 2)
        //
        //        }else if(127<c && c<255){
        //
        //        }
        if( tempC < 255){
            
            if(tempC > 127){
                if(tempC < 210){
                    tempC = Int(CGFloat((tempC + 127)) * 0.43)
                }
                //                tempC = Int(CGFloat((tempC + 255)) * 0.5)
                
            }else{
                //                if(tempC <= 127/2){
                //                }
                tempC = Int(CGFloat(tempC) * 0.5)
                
                
            }
            
            //            tempC = tempC/2
            
            
        }
        
        
        return tempC
    }
    
    class func divideColor(sub:Int)-> [UIColor] {
        
        var tempColor = [UIColor]()
        
        for i in 0 ..< sub {
            
            tempColor.append( UIColor(hue: CGFloat(i)/CGFloat(sub), saturation: 1, brightness: 1, alpha: 1))
            
        }
        
        
        return tempColor
        
    }
    
    
    
}
