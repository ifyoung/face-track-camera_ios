//
//  CameraButton.swift
//  TenStats
//
//  Created by Olivier Destrebecq on 1/16/16.
//  Copyright © 2016 MobDesign. All rights reserved.
//

import UIKit

@IBDesignable
class CameraButton: UIButton {
    //create a new layer to render the various circles
    var pathLayer:CAShapeLayer!
    var animationDuration = 0.4
    enum BtnType {
        case photo
        case video
    }
    
    
    var btnType:BtnType = .video{
        didSet{
            print("btnType-didSet\(btnType)")
            if(btnType == .photo){
                self.pathLayer.fillColor = UIColor.white.cgColor
                self.animationDuration = 0.3
//                self.isSelected = false//放外面有暂停视频的作用。。。没有直接作用通知
                self.pathLayer.removeAllAnimations()
            }else{
                self.pathLayer.fillColor = UIColor.red.cgColor
                self.animationDuration = 0.4
            }
            
            self.setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    //common set up code
    func setup()
    {
        //add a shape layer for the inner shape to be able to animate it
        self.pathLayer = CAShapeLayer()
        
        //show the right shape for the current state of the control
        self.pathLayer.path = self.currentInnerPath().cgPath
        
        //don't use a stroke color, which would give a ring around the inner circle
        self.pathLayer.strokeColor = nil
        
        //set the color for the inner shape
        self.pathLayer.fillColor = UIColor.red.cgColor
        
        //add the path layer to the control layer so it gets drawn
        self.layer.addSublayer(self.pathLayer)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //lock the size to match the size of the camera button
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.width,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute:.height,
                                              relatedBy:.equal,
                                              toItem:nil,
                                              attribute:.width,
                                              multiplier:1,
                                              constant:66.0))
        
        //clear the title
        self.setTitle("", for:UIControl.State.normal)
        
        //add out target for event handling
        self.addTarget(self, action: #selector(touchUpInside), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
    }
    
    
    override func prepareForInterfaceBuilder()
    {
        //clear the title
        self.setTitle("", for:UIControl.State.normal)
    }
    
    override var isSelected:Bool{
        didSet{
            //change the inner shape to match the state
            shapePathAnim()
        }
    }
    
    @objc func touchUpInside(sender:UIButton)
    {
        //Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration;
        colorChange.toValue = UIColor.red.cgColor
        
        //make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = CAMediaTimingFillMode.forwards
        colorChange.isRemovedOnCompletion = false
        
        //indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //add the animation
        
        //change the state of the control to update the shape
        if(btnType == .video){
            self.pathLayer.add(colorChange, forKey:"darkColor")
            //            self.isSelected = !self.isSelected//放到按下里
        }
    }
    
    
    private func shapePathAnim(){
        let morphPath = CABasicAnimation(keyPath: "path")
        morphPath.duration = animationDuration;
        morphPath.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //change the shape according to the current state of the control
        morphPath.toValue = btnType == .photo ? self.innerCirclePathPhoto().cgPath : self.currentInnerPath().cgPath
        
        //ensure the animation is not reverted once completed
        morphPath.fillMode = CAMediaTimingFillMode.forwards
        morphPath.isRemovedOnCompletion = btnType == .photo
        
        //add the animation
        self.pathLayer.add(morphPath, forKey:"")
    }
    
    
    
    @objc func touchDown(sender:UIButton)
    {
        
        shapePathAnim()
        
        //when the user touches the button, the inner shape should change transparency
        //create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration;
        
        //set the value we want to animate to
        //        morph.toValue = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        
        //        morph.toValue = UIColor.init(displayP3Red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        morph.toValue = btnType == .photo ? UIColor.lightGray.cgColor : UIColor.red.cgColor
        
        //ensure the animation does not get reverted once completed
        morph.fillMode = CAMediaTimingFillMode.forwards
        morph.isRemovedOnCompletion = btnType == .photo
        
        
        morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //        self.pathLayer.add(morph, forKey:"morph-color")
        self.pathLayer.add(morph, forKey:"")//加上具体Key值回来会少走一个动画？？
        if(btnType == .video){
            self.isSelected = !self.isSelected
        }
    }
    
    override func draw(_ rect: CGRect) {
        //always draw the outer ring, the inner control is drawn during the animations
        let outerRing = UIBezierPath(ovalIn: CGRect(x:3, y:3, width:60, height:60))
        outerRing.lineWidth = 6
        UIColor.white.setStroke()
        outerRing.stroke()
    }
    
    func currentInnerPath () -> UIBezierPath
    {
        //choose the correct inner path based on the control state
        var returnPath:UIBezierPath;
        if (self.isSelected)
        {
            returnPath = self.innerSquarePath()
        }
        else
        {
            returnPath = self.innerCirclePath()
        }
        
        return returnPath
    }
    
    func innerCirclePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:8, y:8, width:50, height:50), cornerRadius: 25)
    }
    
    func innerCirclePathPhoto () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:13, y:13, width:40, height:40), cornerRadius: 20)
    }
    
    func innerSquarePath () -> UIBezierPath
    {
        return UIBezierPath(roundedRect: CGRect(x:18, y:18, width:30, height:30), cornerRadius: 4)
    }
}
