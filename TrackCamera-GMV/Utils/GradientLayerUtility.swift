//
//  GradientLayerUtility.swift
//  Magic_AM
//
//  Created by qdum_mini_one on 16/2/26.
//  Copyright © 2016年 qdum_mini. All rights reserved.
//

import UIKit

extension CALayer{
    //需添加IBInspectable关键字，Swift3以上？
   @IBInspectable open var borderColorFromUIColor:UIColor{
        
        set(color){
            print("borderColorFromUIColor\(color)")
            self.borderColor = color.cgColor
        }
        get{
            print("borderColorFromUIColor\(UIColor.init(cgColor: self.borderColor!))")
            return UIColor.init(cgColor: self.borderColor!)
        }
    
    }
}

class GradientLayerUtility: NSObject {
    
    class func  getGradientLayer(topColor:UIColor? = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                 buttomColor:UIColor? = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1),
                                 location:[CGFloat]? = [0.0,1.0],
                                 cornerRadius:CGFloat? = CGFloat(5))->CAGradientLayer{
//        let topColor = UIColor(red: (11/255.0), green: (11/255.0), blue: (11/255.0), alpha: 1)
//        let buttomColor = UIColor(red: (35/255.0), green: (35/255.0), blue: (35/255.0), alpha: 1)
        
//        let topColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        let buttomColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        
        let gradientColors: [CGColor] = [topColor!.cgColor, buttomColor!.cgColor]
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.cornerRadius = cornerRadius!
        gradientLayer.borderWidth = 1
        let borderCr = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 0.3952268836)
        gradientLayer.borderColor = borderCr.cgColor
        gradientLayer.masksToBounds = true
        
        return gradientLayer
    }
    
}
