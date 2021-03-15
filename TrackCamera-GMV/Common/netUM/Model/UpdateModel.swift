//
//  DeviceJson.swift
//  Magic_AM
//
//  Created by LingChun on 2018/5/15.
//  Copyright © 2018年 qdum_mini. All rights reserved.
//

import Foundation
struct UpdateModel {
    var id:String = ""//版本号
    var appVersion:String = ""
    var zipSize:String = ""
    var url:String = ""
    var pt:String = ""
    var dev:String = ""
    var createDate:String = ""
    var uid:String = ""
    var projectId:String = ""
    var del:String = ""
    var dateFromate:String = ""
    var tokens:String = ""
    //    var userInfo: [String: Any]
    // Change the dictionary type to [AnyHashable: Any] here...
    var UpdateModelJsonList: String {
        var result: [AnyHashable: Any] = [:]
        // No implicit conversions necessary, since String and Int are subtypes
        // of Any and AnyHashable
        result["id"] = self.id
        result["appVersion"] = self.appVersion
        result["zipSize"] = self.zipSize
        result["url"] = self.url
        result["pt"] = self.pt
        result["dev"] = self.dev
        result["createDate"] = self.createDate
        result["uid"] = self.uid
        result["projectId"] = self.projectId
        result["del"] = self.del
        result["dateFromate"] = self.dateFromate
        result["tokens"] = self.tokens
        
        let jsonData = try! JSONSerialization.data(withJSONObject: (result as? [String: Any])!, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        return jsonString
    }
    
}
