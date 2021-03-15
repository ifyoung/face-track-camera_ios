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

//请求类型：
enum HTTPRequestType {
    case GET
    case POST
}

class NetWorkAFN: AFHTTPSessionManager
    //class NetWorkAFN: AFURLSessionManager
{
    //单例：
    static let shared:NetWorkAFN = {
        let instence = NetWorkAFN.init(sessionConfiguration: URLSessionConfiguration.default)
        
        //        instence.requestSerializer = AFJSONRequestSerializer()
        //        instence.responseSerializer = AFHTTPResponseSerializer()
        //        instence.requestSerializer.setValue("application/json,text/html", forHTTPHeaderField: "Accept")
        //        instence.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return instence
    }()
    
    func request(requestType:HTTPRequestType,urlString:String,parameters:[String:AnyObject]?,complated:@escaping(NSDictionary?)->(),handleFail:@escaping (Error?)->()){
        
        let success = {
            (tasks:URLSessionDataTask,json:Any) ->() in complated(json as? NSDictionary)
        }
        let failure = {
            //            (tasks:URLSessionDataTask?,error:Error) ->() in handleFail(error)
            (tasks:URLSessionDataTask?,error:Error) in
            handleFail(error)
            if let toast = error._userInfo?["NSLocalizedDescription"] as? String{
                GlobalToast.showToastHint(toast)
            }
        }
        
        if requestType == .GET {
            //            get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
            
            self.get(urlString, parameters: parameters, headers: nil, progress:nil, success:success, failure: failure)
            
        }else{
            //            self.post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
            self.requestSerializer.willChangeValue(forKey: "timeoutInterval")
            self.requestSerializer.timeoutInterval = 8
            self.requestSerializer.didChangeValue(forKey: "timeoutInterval")
            self.post(urlString, parameters: parameters, headers: nil, progress:nil, success: success, failure:failure)
        }
    }
    
    
    
}
