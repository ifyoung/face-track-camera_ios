//
//  GuideView.swift
//  SwiftConsultant
//
//  Created by zhoushuai on 17/6/29.
//  Copyright © 2017年 Zhoushuai. All rights reserved.
//

import UIKit

typealias GuideViewEnd = ()->Void
class GuideView: UIView {
    
    //MARK: - Own Properties
    //取上次本地记录的版本号使用到的key
    static let lastAppVersionKey = "lastAppVersionKey"
    let kScreenW = UIScreen.main.bounds.size.width
    let kScreenH = UIScreen.main.bounds.size.height
    var viewType = GuidViewStyle.GuideViewStyle_DisapperForClick
    var guideImages:Array<String> = []
    var guideViewEndVar:GuideViewEnd?
    
    //后期可能会更改引导页的样式，这里使用枚举可以方便应对这种变化
    enum GuidViewStyle{
        case GuideViewStyle_DisapperForClick //点击跳转按钮消失
        case GuideViewStyle_DisapperForFinish //滑过最后一张消失
    }
    
    //滑动视图
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    //分页控制器
    lazy var pageControl:UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: (self.kScreenW - 100)/2, y: self.kScreenH - 100, width: 100, height: 20))
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor .white
        return pageControl
    }()
    
    
    //跳过按钮
    lazy var skipBtn:UIButton = {
        let skipBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        skipBtn.backgroundColor = UIColor.red
        //        let bezierPath = UIBezierPath(roundedRect: skipBtn.bounds,
        //                                byRoundingCorners: [.allCorners], //哪个角
        //                                      cornerRadii: CGSize(width: 5, height: 5)) //圆角半径
        //        let maskLayer = CAShapeLayer()
        //        maskLayer.path = bezierPath.cgPath
        ////        button.layer.mask = maskLayer;
        //        skipBtn.layer.mask = maskLayer
        skipBtn.layer.cornerRadius = 5
        skipBtn.setTitle("str_to_main".localize(), for: UIControl.State.normal)
        skipBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        skipBtn.addTarget(self, action: #selector(skipBtnClicK), for: UIControl.Event.touchUpInside);
        return skipBtn
    }()
    
    
    //MARK: - Life Cycle
    init(images:Array<String>,viewType:GuidViewStyle,endAction:@escaping GuideViewEnd) {
        self.guideImages = images;
        self.viewType = viewType
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.setupUI()
        self.guideViewEndVar = endAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //布局视图
    func setupUI(){
        self.addSubview(self.scrollView)
        for i in 0...guideImages.count - 1 {
            let imgView = UIImageView(frame: CGRect(x:  CGFloat(i) * kScreenW, y: 0, width: kScreenW, height: kScreenH))
            imgView.image = UIImage(named: guideImages[i])
            if(i == guideImages.count - 1){
                imgView.isUserInteractionEnabled = true
                imgView.addSubview(self.skipBtn)
                self.skipBtn.frame = CGRect(x: (kScreenW - 170)/2, y: kScreenH - 29 - 35, width: 175, height: 35);
            }
            self.scrollView.addSubview(imgView)
        }
        
        switch viewType {
        case .GuideViewStyle_DisapperForClick: //必须点击跳过按钮才能消失
            self.scrollView.bounces = false
            self.scrollView.contentSize = CGSize(width: kScreenW * CGFloat(guideImages.count), height: kScreenH)
            self.addSubview(self.pageControl)
            self.pageControl.numberOfPages = self.guideImages.count
            
            break;
        case .GuideViewStyle_DisapperForFinish: //划过最后一张就会消失
            self.scrollView.bounces = false
            self.scrollView.contentSize = CGSize(width: kScreenW * CGFloat(guideImages.count + 1), height: kScreenH)
            self.addSubview(self.pageControl)
            self.pageControl.numberOfPages = self.guideImages.count
        }
        
        //添加按钮
        //        self.addSubview(self.skipBtn)
        //        self.skipBtn.frame = CGRect(x: (kScreenW - 170)/2, y: kScreenH - 29 - 35, width: 175, height: 35);
    }
    
    
    //MARK: - Private Methods
    @objc func skipBtnClicK(){
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0
        }) { (finished) in
            self.removeGuideView()
        }
    }
    
    
    func removeGuideView(){
        self.removeFromSuperview()
        //更新记录此次的版本号到本地
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        UserDefaults.standard.set(currentAppVersion, forKey: GuideView.lastAppVersionKey)
        UserDefaults.standard .synchronize()
        if(self.guideViewEndVar != nil){
            self.guideViewEndVar!()
        }
    }
    
    
    //MARK: - Public Methods
    static func needShowGuideView() ->(Bool){
        //        return true
        //当前工程的版本号
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        //本地记录的版本号
        let lastAppVersion =  UserDefaults.standard.object(forKey: lastAppVersionKey)
        let currentVersion = currentAppVersion as! String
        let lastVersion = lastAppVersion as? String
        if (lastVersion == nil){
            //第一次安装，需要显示引导页
            return true
        }else if(currentVersion != lastVersion){
            //软件升级，需要显示引导页
            return true
        }
        return false
    }
    
    
    //将引导页显示在某个父视图上
    func showGuideViewToSuperView(superView:UIView){
        superView.addSubview(self)
    }
    //将引导页显示在当前应用的KeyWindow上
    func showGuideViewToCurrentWindow(){
        let currentWindow = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
    }
}


//MARK: - Extension - UIScrollViewDelegate
extension GuideView:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch viewType {
        case .GuideViewStyle_DisapperForClick:
            let index = Int(scrollView.contentOffset.x/self.kScreenW)
            if(index < Int(guideImages.count)){
                self.pageControl.currentPage = index;
            }
            break
        case .GuideViewStyle_DisapperForFinish:
            //最后需要点击按钮才能结束展示
            let index = Int(scrollView.contentOffset.x/self.kScreenW)
            if(index < Int(guideImages.count)){
                self.pageControl.currentPage = index;
            }else{
                self.perform(#selector(self.skipBtnClicK), with: nil, afterDelay: 0)
                
            }
            if(scrollView.contentOffset.x > scrollView.contentSize.width - kScreenW * 2){
                //计算此时的偏移大小
                let distance = scrollView.contentOffset.x - scrollView.contentSize.width + kScreenW * 2.0;
                let btnTop = self.skipBtn.frame.origin.y
                let btnWidth = self.skipBtn.frame.size.width
                let btnHeight = self.skipBtn.frame.size.height
                self.skipBtn.frame = CGRect(x: (self.kScreenW - btnWidth)/2 - distance, y: btnTop, width: btnWidth, height: btnHeight)
                //PageControl
                let pageControlTop = self.pageControl.frame.origin.y
                let pageControlWidth = self.pageControl.frame.size.width
                let pageControlHeight = self.pageControl.frame.size.height
                self.pageControl.frame =  CGRect(x: (self.kScreenW - pageControlWidth)/2 - distance, y: pageControlTop, width: btnWidth, height:pageControlHeight)
            }
            //default: break;
        }
    }
}













