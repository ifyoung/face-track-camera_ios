//
//  MetalVideoView.swift
//  Photolyze
//
//  Created by Mac on 07.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import MetalKit

class VideoMetalView: MTKView {
    
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private lazy var commandQueue: MTLCommandQueue? = {
        return self.device!.makeCommandQueue()
    }()
    
    private lazy var content: CIContext = {
        return CIContext(mtlDevice: self.device!, options: [CIContextOption.workingColorSpace : NSNull()])
    }()
    
    var image: CIImage? {
        didSet {
            DispatchQueue.main.async {
                self.draw()
            }
        }
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        device = MTLCreateSystemDefaultDevice()
        setup()
    }
    
    private func setup() {
        framebufferOnly = false
        isPaused = false
        enableSetNeedsDisplay = false
        //colorPixelFormat = .bgra8Unorm
        //contentScaleFactor = UIScreen.main.scale
    }
    
    override func draw(_ rect: CGRect) {
        guard let image = image,
            let currentDrawable = currentDrawable,
            let commandBuffer = commandQueue?.makeCommandBuffer()
            else {
                return
        }
        
        let currentTexture = currentDrawable.texture//只能在真机上运行
        let drawingBounds = CGRect(origin: .zero, size: drawableSize)
        
        let scaleX = drawableSize.width / image.extent.width
        let scaleY = drawableSize.height / image.extent.height
        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        content.render(scaledImage, to: currentTexture, commandBuffer: commandBuffer, bounds: drawingBounds, colorSpace: colorSpace)
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
