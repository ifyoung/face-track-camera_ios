
//

import UIKit

class ToastView: UIView {
    
    var toastTag=101
    var window1:UIView?
    var msg:NSString?
    var hintTextLable:UILabel?
    //带下划线表示前缀名调用时可以省略？？ _ hint
    
    
    typealias isHideAction = (()->Void)
    var isHideActionVar:isHideAction?
    
    
    func showToastHint(_ hint:String,hideResult:isHideAction? = nil) {
        DispatchQueue.main.async {
            self.showToastHintM(hint,hideResult)
        }
    }
    
    
    func popTopTip(_ hint:String,Color:UIColor) {
        DispatchQueue.main.async {
//            self.showToastHintM(hint,hideResult)
            self.popTopNotice(color: Color, tip: hint)
        }
    }
    
    
    
    
    private func showToastHintM(_ hint:String,_ hideResult:isHideAction? = nil){
        
        self.window1 = UIApplication.shared.delegate!.window!
        if (self.window1!.viewWithTag(toastTag) != nil){
            print("onSaveState\(hint)")
//            if(!hint.contains("yl_save_success".localize())){
//                return;//正在显示
//            }
        }
        
        let maxLabelW=ceil(UIScreen.main.bounds.width*0.7)
        
        var width = (hint as NSString).stringWidthWith(14)
        width = width > maxLabelW ? maxLabelW : width
        
        let height = (hint as NSString).stringHeightWith(14, width: width) + 24
        
        width += 40
        
        let x = UIScreen.main.bounds.width/2.0 - width/2.0
//        let y = UIScreen.main.bounds.height/2.0 - height/2.0
        let y = UIScreen.main.bounds.height*0.8 - height/2.0
        
        let view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
//        view.backgroundColor=UIColor.clear
        
        let viewBg = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        viewBg.layer.cornerRadius=5
        viewBg.backgroundColor=UIColor.gray.withAlphaComponent(0.8)
        viewBg.alpha=1
        view.addSubview(viewBg)
        
        
        let textLable=UILabel(frame: CGRect(x: 20, y: 12, width: width-40, height: height-24))
        textLable.textAlignment=NSTextAlignment.center
        textLable.font=UIFont.systemFont(ofSize: 14)
        //        textLable.text=hint
        textLable.setTextLines(hint)
        textLable.textColor=UIColor.white
        //        textLable.numberOfLines=2
        view.addSubview(textLable)
        //view.alpha=0.3
        self.window1!.addSubview(view)
        UIView.animate(withDuration: 0.5, delay:0.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            view.alpha=1.0
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, delay: 1.8, options: UIView.AnimationOptions(rawValue: 0), animations: {
                view.alpha=0.0
            }, completion: {finished in
                view.removeFromSuperview()
                if(hideResult != nil){
                    hideResult!()
                    
                }
            })
        })
    }
    
    
    func showToastLoading(_ hint:String,viewTag:Int? = nil){
        //闪屏？？
//        DispatchQueue.main.async {
//        }
        self.showToastLoadingM(hint,viewTag)

    }
    
    
    
    //    let operationQueueSend = OperationQueue()
//    let loadingOpera = OperationQueue()
    var loadingTimer:Timer? = nil
    private func showToastLoadingM(_ hint:String,_ viewTag:Int? = nil){
        self.window1 = UIApplication.shared.delegate!.window!
        if (self.window1!.viewWithTag(toastTag) != nil){
            self.window1!.viewWithTag(self.toastTag)!.removeFromSuperview()
        }
        //        loadingOpera.cancelAllOperations()
        if(loadingTimer != nil){
            loadingTimer?.invalidate()
            loadingTimer = nil
        }
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor=UIColor.black.withAlphaComponent(0.3)
        view.alpha=0.3
        if(viewTag != nil){
            hideLoading()
            //            toastTag = viewTag!
            view.tag=viewTag!
            
        }else{
            view.tag=toastTag
            
        }
        
//        let viewBg = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        viewBg.backgroundColor=UIColor.black
//        viewBg.alpha=0.6
//        view.addSubview(viewBg)
        
        let hintWidth = (hint as NSString).stringWidthWith(14) + 70
        let hintHeight:CGFloat = 50
        
        let hintView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2-hintWidth/2,y: UIScreen.main.bounds.height/2-30,width: hintWidth,height: hintHeight))
        hintView.layer.cornerRadius = 5
        hintView.layer.masksToBounds = true
//        UIColor.black.withAlphaComponent(0.3)
//        hintView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        hintView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        let activityView = UIActivityIndicatorView(frame: CGRect(x: 20,y: hintHeight/2-10,width: 20,height: 20))
        activityView.style=UIActivityIndicatorView.Style.white
        activityView.startAnimating()
        hintView.addSubview(activityView)
        
        hintTextLable = UILabel(frame: CGRect(x: 50,y: 0,width: hintView.width()-70,height: hintHeight))
        hintTextLable!.textColor = UIColor.white
        hintTextLable!.font = UIFont.systemFont(ofSize: 14)
        hintTextLable!.text = hint
        
        
        hintView.addSubview(hintTextLable!)
        
        view.addSubview(hintView)
        
      
        self.window1!.addSubview(view)
        UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            view.alpha=1.0
        }, completion: { finished in
        })
//        loadingOpera.maxConcurrentOperationCount = 1
        
//        let isOld = Global.getBleName(nameKey: NEWNAME).contains("MagicAir")
//        let timeDelay = isOld ? 5.0 : 7.0
        let timeDelay = 5.0
        
        
        if(loadingTimer==nil){
            loadingTimer=Timer.scheduledTimer(timeInterval: timeDelay, target: self, selector: #selector(hindTimer), userInfo: nil, repeats: false)//间隔2秒
        }
        
        
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeDelay) {
        //
        //            self.loadingOpera.addOperation {
        //                DispatchQueue.main.async {
        //                    if (self.window1!.viewWithTag(view.tag) != nil){
        //
        //                        self.hideLoading()
        //
        //                        print("大延时\(isOld)")
        //                    }
        //                }
        //
        //            }
        //
        //
        //        }
        
        
        
    }
    
    @objc func  hindTimer(){
        print("大延时")
//        self.hideLoadingM()
        DispatchQueue.main.async {
            self.hideLoadingM()
        }
    }
    
    func hideLoading(viewTag:Int?=nil,finish:(()->Void)? = nil){
        
        DispatchQueue.main.async {
            self.hideLoadingM(viewTag,finish)
        }
    }
    
    private func hideLoadingM(_ viewTag:Int?=nil,_ finish:(()->Void)? = nil){
        if(self.window1 == nil ){
            return
        }
        
        let tagV = (viewTag == nil) ? toastTag : viewTag
        
        if (self.window1!.viewWithTag(tagV!) != nil){
            UIView.animate(withDuration: 0.3, delay:0.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.window1!.viewWithTag(tagV!)!.alpha=0.0
            }, completion: { finished in
                if (self.window1!.viewWithTag(tagV!) != nil){
                    self.window1!.viewWithTag(tagV!)!.removeFromSuperview()
                    //                        print("在哪儿消失:\(which)")
                    if(finish != nil){
                        finish!()
                    }
                }
            })
        }
    }
    
    func isLoading(viewTag:Int?=nil,state:@escaping ((Bool)->Void)){
        //有异步，用标志返回时间线不好控制,所以用回调
        //        var isLoading = false
        DispatchQueue.main.async {
            state(self.isLoadingM(viewTag))
        }
        //        return isLoading
        
        
    }
    
    private func isLoadingM(_ viewTag:Int?=nil)->Bool{
        if(self.window1 == nil ){
            return false
        }
        let tagV = (viewTag == nil) ? toastTag : viewTag
        
        if (self.window1!.viewWithTag(tagV!) != nil){
            return true
        }
        return false
    }
    
    func timeLaterShow(_ hint:String){
        msg=hint as NSString?
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(ToastView.show), userInfo: nil, repeats: false)
    }
    
    func timeLaterMainShow(_ hint:String){
        msg=hint as NSString?
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ToastView.show), userInfo: nil, repeats: false)
    }
    
    
    
    @objc func show(){
        // [weak self]()防止内存泄漏？？此实例有销毁为空的情况？
        DispatchQueue.main.async { [weak self]() in
            if(self?.msg != nil){
                self?.showToastHint((self?.msg)! as String)
            }
        }
        
    }
    
}

extension UILabel{

func setTextS(_ textS:String){
    var textS = textS
    
    let height = (textS as NSString).stringHeightWiths(self.font, width: self.width())
    
    if(self.numberOfLines != 1){
        
        let line = Int(height/self.font.lineHeight)
        for _ in line..<self.numberOfLines{
            textS+="\n"+" "
        }
    }
    self.text = textS
}

func setTextLines(_ textS:String){
    
    let height = (textS as NSString).stringHeightWiths(self.font, width: self.width())
    let line = ceil(height/self.font.lineHeight)
    self.numberOfLines = Int(line)
    self.text = textS
    }
    
}
