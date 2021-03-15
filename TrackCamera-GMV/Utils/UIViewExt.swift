//
//

import UIKit
import Foundation
extension UIView  {
    
   @objc func x()->CGFloat
    {
        return self.frame.origin.x
    }
   @objc func right()-> CGFloat
    {
        return self.frame.origin.x + self.frame.size.width
    }
   @objc func y()->CGFloat
    {
        return self.frame.origin.y
    }
    func bottom()->CGFloat
    {
        return self.frame.origin.y + self.frame.size.height
    }
   @objc func width()->CGFloat
    {
        return self.frame.size.width
    }
   @objc func height()-> CGFloat
    {
        return self.frame.size.height
    }
    
   @objc func setX(_ x: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.origin.x = x
        self.frame = rect
    }
    
    func setRight(_ right: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.origin.x = right - rect.size.width
        self.frame = rect
    }
    
   @objc func setY(_ y: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.origin.y = y
        self.frame = rect
    }
    
   @objc func setBottom(_ bottom: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.origin.y = bottom - rect.size.height
        self.frame = rect
    }
    
   @objc func setWidth(_ width: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.size.width = width
        self.frame = rect
    }
    
   @objc func setHeight(_ height: CGFloat)
    {
        var rect:CGRect = self.frame
        rect.size.height = height
        self.frame = rect
    }
    
    //加载xib
    func loadFromNib(_ nibname: String? = nil,data:[UINib.OptionsKey : Any]? = nil) -> [UIView] {//Self (大写) 当前类对象
        //self(小写) 当前对象
        let loadName = nibname == nil ? "\(self)" : nibname!
        let op = data
//        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! UIView
        //多个的话
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: op) as! [UIView]
  
    }
    //返回该view所在VC ？？？不准
    func firstViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        
        return nil
    }
    
    func setCornerShape(width:CGFloat = 1,Ra:CGFloat = 10,CorColor:UIColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1) ){
        
        layer.cornerRadius = Ra
      
        layer.borderColor = CorColor.withAlphaComponent(0.6).cgColor

        layer.borderWidth = width
        layer.masksToBounds = true
//        layer.borderColor = UIColor.init(white: 0.6, alpha: 0.6)

    }
    
    
    //背景渐变
    func insertGradientLayer(outerView:UIView? = nil,topColor:UIColor? = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),buttomColor: UIColor? = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1),location:[CGFloat]? = [0.0,1.0],widthEx:CGFloat? = 0,heightEx:CGFloat? = 0) {
        
        let gradientLayer = GradientLayerUtility.getGradientLayer(topColor:topColor ,buttomColor: buttomColor,location:location,cornerRadius:0)
        if(widthEx != 0 || heightEx != 0){
            if(widthEx != 0){
                gradientLayer.frame = CGRect(x: 0, y: 0, width: widthEx!, height: frame.height)
            }else{
                gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: heightEx!)
            }
            
        }else{
            gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
        
        gradientLayer.opacity = 0.8
        if(outerView == nil){
            layer.insertSublayer(gradientLayer, at: 0)

        }else{
            outerView?.layer.insertSublayer(gradientLayer, at: 0)

        }
        
    }
    

//
//    typealias gestureRecognizerAction = ((String) -> Void)?
//    fileprivate struct AssociatedObjectKeys {//缓存，不能实时点击的视图？？
//        static var tap:gestureRecognizerAction
//        }
//    var tap:gestureRecognizerAction{
//        set { AssociatedObjectKeys.tap = newValue }
//        get { return AssociatedObjectKeys.tap}
//    }
//    // This is the meat of the sauce, here we create the tap gesture recognizer and
//    // store the closure the user passed to us in the associated object we declared above
//    func addTapGestureRecognizer(action: gestureRecognizerAction) {
//        self.isUserInteractionEnabled = true
//        tap = action
//        //mark-添加手势
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
//        self.addGestureRecognizer(tapGestureRecognizer)
//    }
//
//
//    // Every time the user taps on the UIImageView, this function gets called,
//    // which triggers the closure we stored
//    @objc func handleTapGesture(_ sender:UITapGestureRecognizer) {
//
//        print("Pop-handleTapGesture\(sender)")
//        if(tap != nil){
//            tap!("tap")
//
//        }
//        AssociatedObjectKeys.tap = nil
////        if let action = self.tapGestureRecognizerAction {
////            action?()
////        } else {
////            print("no action")
////        }
//
//
//    }
//
    
    
    
}
