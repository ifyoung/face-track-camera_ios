//
//  NibExampleView.swift
//  Core-Sample
//
//  Created by Elias Abel on 4/25/18.
//  Copyright (c) 2018 Meniny Lab. All rights reserved.
//

import UIKit
import WebKit
import Pow
class NibWebView: UIView, WKUIDelegate, WKNavigationDelegate {
    
    /**
     特别特别注意映射是来自filerOner还是具体view
     */
    @IBOutlet weak var wbKitView: WKWebView!
    
    @IBOutlet weak var btnH: NSLayoutConstraint!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBAction func agreeClick(_ sender: Any) {
        Global.saveLocal("privacy", nameKey: "privacy")
        
        Pow.dismiss()
    }
    @IBAction func exitClick(_ sender: Any) {
        onExit()
    }
    @IBOutlet weak var exitBtn: UIButton!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fromNib()
        //      let contentView =  loadFromNib("NibWebView")[0]
        
        //        addSubview(contentView)
        //        contentView.fillSuperview()
        //        inItWebView()
        //    let targetUrl = "https://gamepress.gg/epicseven/camping-simulator"
        //
        //
        //   let urlRequest = URLRequest(url:URL(string:targetUrl)!)
        //        let t = wb
        //   wb.loadRequest(urlRequest)
    }
    
    
    
    //退出应用
    func onExit(){
        
        //        if(NetWork.sharedManager != nil){
        //        }
        NetWork.sharedManager.session.invalidateAndCancel()
        
        let app = UIApplication.shared.delegate
        let window = app!.window
        
        CAAnimeM.init().animeScaleSmall(view: window!!,dura: 0.1) { (isFinish) in
            if(isFinish){
                exit(0)
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       let currentLang = (NSLocale.preferredLanguages[0] as String)
        print("awakeFromNib-lang\(currentLang)")
        var targetUrl = "https://snp-us.top/ydcp/sp/protocol"
        
        if(currentLang.contains("fr")){
            targetUrl = targetUrl + "?language=fr"
        }else if(currentLang.contains("zh")){
            targetUrl = targetUrl + "?language=zh"
        }else if(currentLang.contains("en")){
            targetUrl = targetUrl + "?language=en"
        }else if(currentLang.contains("ko")){
            targetUrl = targetUrl + "?language=ko"
        }else if(currentLang.contains("ja")){
            targetUrl = targetUrl + "?language=ja"
        }
        
        
        let urlRequest = URLRequest(url:URL(string:targetUrl)!)
        //        wb.loadRequest(urlRequest)
//        wbKitView.uiDelegate = self
        wbKitView.navigationDelegate = self;
        wbKitView.load(urlRequest)
        if(Global.getLocalData(nameKey: "privacy") != EMPTYVARCHAR){//非第一次
            agreeBtn.setTitle("str_close".localize(), for: UIControl.State.normal)
            exitBtn.isHidden = true
        }
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
//        completionHandler(.useCredential, cred)
        
        // 判断服务器采用的验证方法
               if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                   if challenge.previousFailureCount == 0 {
                       // 如果没有错误的情况下 创建一个凭证，并使用证书
                       let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                       completionHandler(.useCredential, credential)
                   } else {
                       // 验证失败，取消本次验证
                       completionHandler(.cancelAuthenticationChallenge, nil)
                   }
               } else {
                   completionHandler(.cancelAuthenticationChallenge, nil)
               }
    }
    
    init() {
        super.init(frame: .zero)
        fromNib()//唤醒
        //        let contentView =  loadFromNib("NibWebView")[0]
        //
        //               addSubview(contentView)
        //               contentView.fillSuperview()
        //        var s:NSString = "https://snp-us.top/ydcp/sp/protocol"
        //        s.addingPercentEncoding(withAllowedCharacters: CharacterSet)
        //               let r = URL.init(string:s as String)
        //
        //        webView.load(URLRequest.init(url:URL.init(string: "http://www.apple.com")!))
        //
        
    }
}
