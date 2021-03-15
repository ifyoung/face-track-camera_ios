//
//  CATextLayerTests.swift
//  CATextLayerTests
//
//  Created by David Perkins on 10/15/17.
//  Copyright © 2017 David Perkins. All rights reserved.
//
import UIKit


class CAAnimeM: NSObject,CAAnimationDelegate {
    
    func animeArc(layer:CAShapeLayer){
        //添加动画
        let pathAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        pathAnimation.duration = 1
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        layer.add(pathAnimation, forKey: "animeArc")
    }
    
    func animePop(layer:CALayer){
        let pathAnimation = CABasicAnimation.init(keyPath: "transform.translation.y")
        pathAnimation.duration = 1
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        pathAnimation.fromValue = layer.bounds.height
        pathAnimation.toValue = 0
        pathAnimation.autoreverses = true
        pathAnimation.repeatCount = .infinity
        layer.add(pathAnimation, forKey: "animePop")
        //        layer.removeAnimation(forKey: "animePop")
    }
    
    func animeSwing(layer:CALayer,path:CGPath){
        let pathAnimation = CAKeyframeAnimation.init(keyPath: "position")
        pathAnimation.duration = 1
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        pathAnimation.path = path
        pathAnimation.autoreverses = true
        pathAnimation.repeatCount = .infinity
        
        layer.add(pathAnimation, forKey: "animeSwing")
        //        layer.removeAnimation(forKey: "animePop")
    }
    
    //bounds.size 大小，bounds大小与位置
    func animeDot(layer:CALayer,bounds1:CGRect,bounds2:CGRect){
        let pathAnimation = CAKeyframeAnimation.init(keyPath: "bounds.size")
        pathAnimation.duration = 2
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        
        pathAnimation.values = [bounds1.size,bounds2.size]
        pathAnimation.autoreverses = true
        pathAnimation.repeatCount = .infinity
        
        layer.add(pathAnimation, forKey: "animeDot")
        //        layer.removeAnimation(forKey: "animePop")
    }
    
    //上移实际位置不变
    func animeUpMove(layer:CALayer,distance:CGFloat!){
        let animationPos = CABasicAnimation.init(keyPath: "transform.translation.y")
        animationPos.duration = distance < 0 ? 0.7 : 0.3
        //        animationPos.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        //        animationPos.fromValue = frame.minY
        animationPos.toValue = distance
        animationPos.isRemovedOnCompletion = false
        animationPos.fillMode = CAMediaTimingFillMode.forwards
        animationPos.delegate = self
        
        animationPos.setValue(layer, forKey: "animeUpMovePosLayer")
        animationPos.setValue(distance, forKey: "animeUpMovePosLayerPosY")
        layer.add(animationPos, forKey: "animeUpMove")
        
        
    }
    
    func animeUpMovePos(layer:CALayer,distance:CGFloat!){
        let animationPos = CABasicAnimation.init(keyPath: "position.y")
        let posY = layer.frame.minY + distance
        
        
        
        animationPos.duration = 0.4
        animationPos.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        animationPos.fromValue = layer.frame.minY
        animationPos.delegate = self
        animationPos.toValue = posY
        animationPos.isRemovedOnCompletion = false
        animationPos.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animationPos, forKey: "animeUpMovePos")
        
        
    }
    //放大
    func animeScaleBig(view:UIView,
                       dura:TimeInterval = 0.3,
                       damping:TimeInterval = 0.7,
                       animtionOptions : UIView.AnimationOptions =
        UIView.AnimationOptions.curveEaseOut,
                       completion : ((Bool)->Void)? = nil){
        view.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: dura, delay: 0, usingSpringWithDamping:CGFloat(damping), initialSpringVelocity: 0 ,options: animtionOptions, animations: {
            //            self.backView.alpha = 0.5
            view.transform = CGAffineTransform.identity
        }, completion : { finished in
            completion?(finished)
            //            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    //缩小
    func animeScaleSmall(view:UIView,
                         dura:TimeInterval = 0.3,
                         damping:TimeInterval = 0.7,
                         animtionOptions : UIView.AnimationOptions =
        UIView.AnimationOptions.curveEaseOut,
                         completion : ((Bool)->Void)? = nil){
        //        view.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: dura, delay: 0, usingSpringWithDamping:CGFloat(damping), initialSpringVelocity: 0 ,options: animtionOptions, animations: {
            //            self.backView.alpha = 0.5
            view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            view.alpha = 0.1
        }, completion : { finished in
            completion?(finished)
            view.transform = CGAffineTransform.identity
            
            //            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if(flag){
            if(anim.value(forKey: "animeUpMovePosLayer") != nil){
                
                let l = anim.value(forKey: "animeUpMovePosLayer") as! CALayer
                let dis = anim.value(forKey: "animeUpMovePosLayerPosY") as! CGFloat
                let posY = l.frame.minY + dis
                print("移动动画A\(posY)-->\(l.frame.origin.y)-->\(dis * 0.8)-->\(dis)")
                //防快速点击176.8,382.0,206
                if(posY < abs(dis * 2.5)  && posY > abs(dis * 0.8)  ){
                    l.frame.origin.y = posY
                }
                l.removeAllAnimations()//???
                
                
                print("移动动画B\(posY)-->\( l.frame.origin.y)")
                
                
                
            }
        }
        
    }
    
    
    func stopAnim(layer:CALayer?,key:String){
        if(layer != nil){
            layer?.removeAnimation(forKey: key)
            
        }
    }
    
    
    // 创建基础Animation
    func createAnimation (keyPath: String, toValue: CGFloat,durationTime:CFTimeInterval? = 1,repeatTimes:Float? = 0) -> CABasicAnimation {
        //创建动画对象
        let scaleAni = CABasicAnimation()
        //设置动画属性
        scaleAni.keyPath = keyPath
        
        //设置动画的起始位置。也就是动画从哪里到哪里。不指定起点，默认就从positoin开始
        scaleAni.toValue = toValue
        
        //动画持续时间
        scaleAni.duration = durationTime!
        scaleAni.isRemovedOnCompletion = false
        scaleAni.fillMode = CAMediaTimingFillMode.forwards
        //动画重复次数
        //        scaleAni.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        scaleAni.repeatCount = repeatTimes!
        return scaleAni;
    }
    
    // 创建基础Animation
    func createAnimationGroup(keyPaths: [String], toValue: CGFloat,durationTime:CFTimeInterval? = 1,repeatTimes:Float? = 0) -> CAAnimationGroup {
        //创建动画对象
        let groupAnimation = CAAnimationGroup()
//        groupAnimation.beginTime = CACurrentMediaTime() + 0.1
        groupAnimation.duration = durationTime!
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        var animParts = [CAAnimation]()
        for i in keyPaths {
            let animPart = CABasicAnimation(keyPath: i)
            animPart.toValue = 0
            animParts.append(animPart)
            
        }
        groupAnimation.animations = animParts

        //动画重复次数
        //        scaleAni.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
//         = [scaleDown, fade]
        return groupAnimation
    }
    
    
    
    //    // 创建组动画
    //    let groupAnimation = CAAnimationGroup()
    //    groupAnimation.beginTime = CACurrentMediaTime() + 0.5
    //    groupAnimation.duration = 0.5
    //    groupAnimation.fillMode = kCAFillModeBackwards
    //
    //    /**
    //     1. “子动画”不需要在设置duration、fillMode等属性
    //     2. “子动画”的duration、fillMode将使用“组动画”的设置
    //     */
    //    // 缩放效果（创建子动画）
    //    let scaleDown = CABasicAnimation(keyPath: "transform.scale")
    //    scaleDown.fromValue = 3.5
    //    scaleDown.toValue = 1.0
    //
    //    // 旋转效果（创建子动画）
    //    let rotate = CABasicAnimation(keyPath: "transform.rotation")
    //    rotate.fromValue = .pi / 4.0
    //    rotate.toValue = 0.0
    //
    //    // 透明度变化效果（创建子动画）
    //    let fade = CABasicAnimation(keyPath: "opacity")
    //    fade.fromValue = 0.0
    //    fade.toValue = 1.0
    //
    //    // 组合动画（将子动画组合到组动画中）
    //    groupAnimation.animations = [scaleDown, rotate, fade]
    //    loginButton.layer.add(groupAnimation, forKey: nil)
    //
    //    作者：断忆残缘
    //    链接：https://www.jianshu.com/p/036727f559d6
    //    來源：简书
    //    简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
    
    
    /**
     *  抖动动画
     *
     *  @param times     晃动的次数
     *  @param direction 标记:形变是往左还是往右
     *  @param current   已经晃动的次数
     *  @param delta     形变水平距离
     *  @param interval  每次晃动的时间
     */
    //    - (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval {
    //
    //    [UIView animateWithDuration:interval animations:^{
    //    self.transform = CGAffineTransformMakeTranslation(delta * direction, 0);
    //    } completion:^(BOOL finished) {
    //    if(current >= times) {
    //    self.transform = CGAffineTransformIdentity;
    //    if (self.completionBlock) {
    //    self.completionBlock();
    //    }
    //
    //    }else {
    //
    //    [self _shake:(times - 1)
    //    direction:direction * -1
    //    currentTimes:current + 1
    //    withDelta:delta
    //    andSpeed:interval];
    //    }
    //    }];
    //    }
    
    
    
    
    
}
