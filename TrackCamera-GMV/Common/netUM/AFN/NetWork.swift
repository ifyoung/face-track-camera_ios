//
//  NetWork.swift
//  Magic_AM
//
//  Created by LingChun on 2017/12/1.
//  Copyright © 2017年 qdum_mini. All rights reserved.
//

import UIKit

//typealias onGetSuccessClosure = () -> Void

//TODO - session的淘汰策略

//let STATICMEDIAPATH_KEY = "STATICMEDIAPATH_KEY"
//let STATICMEDIALAUNCH_FLAG = "LaunchMediaFlag"
//let STATICMEDIALAUNCH_DIR = "Media"


public enum UPDATE_RES:Int{
    //    下载占用区间0～1
    case DownloadErr = -1
    case DownloadFinish = 1
    case CheckUpIsLatest = 2
    case CheckUpErr = -2
    //    case
}



typealias CallResult = ((String) -> Void)?



struct NetWork {
    //    var onSuccessItem:onGetSuccessClosure!
    
    //    var callRes:CallResult

    
    
    static let sharedManager:NetWorkAFN = {
        
        let manager = NetWorkAFN.shared
        return manager
    }()
    
    
    
    
    
    static func checkActive(callResult:CallResult){
        let appUDID = Global.getBleName(nameKey: "suitId")
        if(appUDID == EMPTYVARCHAR || appUDID.contains("Can't")){
            if(callResult != nil){
                callResult!("获取设备标识失败")
            }
            return
        }
        //        encryptAppId = encryptAppId.AesEncrypt()
        //        var code = "{\"type\":\"ios\",\"appid\":\"aaaaaaaaaaaaaaaaaaqqqqqqqqqqqqq\"}"
        var code = "{\"type\":\"ios\",\"appid\":\""+appUDID+"\"}"//注意转义
        code = code.AesEncrypt()
        let parameters: [String:AnyObject] = ["code":code] as [String:AnyObject]
        
        NetWork.sharedManager.request(requestType: .GET, urlString: GetAPPKeyURL, parameters: parameters,complated: { (response) in
            print("NetWork-checkActive：\(String(describing: response))")
            if(response != nil){
                if(response?.value(forKey: "status") as? Int == 200){
                    let resData = response!.value(forKey: "data")
                    if(resData == nil){
                        return
                    }
                    
                    if let resInfo = resData as? NSDictionary{
                        ASF_APPID = resInfo.value(forKey: "appId") as! String
                        ASF_SDKKEY = resInfo.value(forKey: "appSdkkey") as! String
                    }
                    if(callResult != nil){
                        print("ASF_APPID>>\(ASF_APPID)>>>ASF_SDKKEY\(ASF_SDKKEY)")
                        callResult!("success")
                    }
                }else{
                    print("检查更新，暂无更新\(String(describing: response!.value(forKey: "message")))")
                    if(callResult != nil){
                        callResult!(String(describing: response!.value(forKey: "message")))
                    }
                }
            }
        },handleFail: {
            (err) in
            if(callResult != nil){
                callResult!(UPDATE_RES.CheckUpErr.rawValue.description)
            }
            print("handleFail-checkUpdate\(String(describing: err))")
            //            if(err != nil){
            //                GlobalToast.showToastHint(String.init(describing: err!._userInfo?["NSLocalizedDescription"]))
            //            }
        })
        
    }
    
    
    static func checkUpdateAPP(callResult:CallResult){
        
        NetWork.sharedManager.request(requestType: HTTPRequestType.GET, urlString: "https://itunes.apple.com/lookup?bundleId=com.Apai.Go", parameters:nil, complated: { (response) in
            let t = response
            if(response != nil){
                if let resData = response?.value(forKey: "results") as? [NSDictionary]{
                    if(resData.count > 0){
                        let  ver = resData[0].value(forKey: "version")
                        //                    有新版本
                        if(appVersion.versionCompareUP(strLoc: appVersion, strSer: ver as! String))
                            //                    if(appVersion.versionCompareUP(strLoc: ver as! String, strSer: appVersion))
                        {
                            
                            callResult!("update")
                            
                            
                        }
                    }
                    
                }
            }
        }) { (err) in
            
        }
    }
    
}
