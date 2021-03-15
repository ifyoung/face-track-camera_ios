//
//  ResizingButton.swift
//  Photolyze
//
//  Created by Mac on 05.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import UIKit

class ResizingButton: UIButton {
    
    private var currentFrame: CGRect = .zero
    private var cornerRadius: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(frame: CGRect, cornerRadius: CGFloat) {
        self.currentFrame = frame
        self.cornerRadius = cornerRadius
    }
    
    func resize(scaleCoeff: CGFloat = 1.0, animated: Bool = true, duration: Double = 0.3) {
        
        let resizeAction = {
            let sizeDiff = self.currentFrame.size.width * scaleCoeff - self.frame.size.width
            self.frame.origin.x -= sizeDiff/2
            self.frame.origin.y -= sizeDiff/2
            self.frame.size.height += sizeDiff
            self.frame.size.width += sizeDiff
            self.layer.cornerRadius = self.cornerRadius * scaleCoeff
        }
        
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveLinear,
                animations: {
                    resizeAction()
            },
                completion: { isFinished in
                    self.layoutIfNeeded()
            }
            )
        } else {
            resizeAction()
        }
        
    }
    
}
