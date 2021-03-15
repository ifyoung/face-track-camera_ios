//
//  Extentions.swift
//  DynamicBlurView
//
//  Created by Mohammad on 5/31/18.
//

import UIKit


extension UIView {
 
    // src : https://medium.com/@sdrzn/adding-gesture-recognizers-with-closures-instead-of-selectors-9fb3e09a8f0b
    fileprivate struct AssociatedObjectKeys {//key值唯一，可自定义
        static var tapGestureRecognizer = "tapGestureRecognizerExt"
    }
    
//     typealias Action = ((String) -> Void)?
     typealias Action = ((UITapGestureRecognizer) -> Void)?
    
    
//    fileprivate struct AssociatedObjectKeys {
//        static var tapGestureRecognizer : Action
//    }
    
     //Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
//    fileprivate var tapGestureRecognizerAction: Action? {
//        set {//会记录最后一次的？？？
//            AssociatedObjectKeys.tapGestureRecognizer = newValue as! ((String) -> Void)
//        }
//        get {
//
//            return AssociatedObjectKeys.tapGestureRecognizer
//        }
//    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
     func addTapGestureRecognizer(action: Action) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?(sender)
        } else {
            print("no action")
        }
    }
}

