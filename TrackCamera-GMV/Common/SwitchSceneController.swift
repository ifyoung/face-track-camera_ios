//
//  SwitchSceneController.swift
//  TrackCamera_GMV
//
//  Created by LCh on 2020/8/21.
//  Copyright © 2020 LC. All rights reserved.
//

//场景切换界面
//import UIKit
import Foundation
import ReplayKit

class SwitchSceneController:UIViewController{
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    @IBOutlet weak var livebtn: UIButton!
    
    @IBOutlet weak var camerabtn: UIButton!
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var btnContentView: UIStackView!
    
    @IBAction func liveClick(_ sender: Any) {
//        ios12Action()
//        self.perform(Selector.init("startLive"))
        if let actionView = btnContentView.viewWithTag(0x127){
            actionView.subviews.forEach { (subView) in
//                if(type(of: subView) is UIButton.Type){
                if(type(of: subView) == UIButton.self){
                    (subView as! UIButton).sendActions(for: UIControl.Event.touchUpInside)
                }
            }
        }

    }

    @IBAction func cameraClick(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "main")
        if let appDele = AppDelegateMain{
//            appDele.launch(mainVC)
             appDele.window?.currentViewController()?.navigationController!.pushViewController(mainVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        ios12Action()
        if(Global.isIphoneX()){
            topMargin.constant = 550
        }
    }
    
    
    func ios12Action(){
        if #available(iOS 12.0, *) {
            let picker = RPSystemBroadcastPickerView.init(frame: livebtn.frame)
//            picker.center = livebtn.center
            picker.preferredExtension = "com.Apai.Go.TackLive"
//            picker.alpha = 0
            picker.tag = 0x127
            print("ios12Action>>\(livebtn.frame)>>\(livebtn.center)>>\(picker.frame)")
//            self.livebtn.addSubview(picker)
//            btnContentView.insertSubview(picker, at: 0)
            btnContentView.addSubview(picker)
            btnContentView.bringSubviewToFront(livebtn)
//            self.view.bringSubviewToFront(livebtn)
//            self.livebtn.bringSubviewToFront(livebtn)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    
}
