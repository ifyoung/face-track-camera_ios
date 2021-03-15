
//extension FilteredCameraBBMetal: AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
extension FilteredCameraBBMetal: BBMetalCameraMetadataObjectDelegate {
    func camera(_ camera: BBMetalCamera, didOutput metadataObjects: [AVMetadataObject]) {
        guard let first = metadataObjects.first else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.faceView.isHidden = true
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.handleMetadataBounds(first.bounds)
        }
    }
    
    private func handleMetadataBounds(_ bounds: CGRect) {
        let imageWidth: CGFloat = 1080
        let imageHeight: CGFloat = 1920
        let aa: CGFloat = imageWidth / imageHeight
        let bb: CGFloat = metalView.bounds.width / metalView.bounds.height
        
        // top x, right y
        let x = camera.position == .front ? bounds.minY : 1 - bounds.maxY
        let y = bounds.origin.x
        
        // x' = sx * x + tx
        // y' = sy * y + ty
        var sx: CGFloat = metalView.bounds.width
        var tx: CGFloat = 0
        var sy: CGFloat = metalView.bounds.height
        var ty: CGFloat = 0
        
        var displayImageWidth = imageWidth
        var displayImageHeight = imageHeight
        
        if aa > bb {
            // Mask left and right
            displayImageWidth = imageHeight * bb
            let maskImageMarginLeft = abs(imageWidth - displayImageWidth) * 0.5
            tx = -maskImageMarginLeft / displayImageWidth * metalView.bounds.width
            sx = (1 + maskImageMarginLeft / displayImageWidth) * metalView.bounds.width - tx
            
        } else {
            // Mask top and bottom
            displayImageHeight = imageWidth / bb
            let maskImageMarginTop = abs(imageHeight - displayImageHeight) * 0.5
            ty = -maskImageMarginTop / displayImageHeight * metalView.bounds.height
            sy = (1 + maskImageMarginTop / displayImageHeight) * metalView.bounds.height - ty
        }
        
        UIView.animate(withDuration: 0.3) {
            var frame: CGRect = .zero
            frame.origin.x = sx * x + tx
            frame.size.width = bounds.height * imageWidth / displayImageWidth * self.metalView.bounds.width
            frame.origin.y = sy * y + ty
            frame.size.height = bounds.width * imageHeight / displayImageHeight * self.metalView.bounds.height
            if frame.minX >= 0,
                frame.maxX <= self.metalView.bounds.width,
                frame.minY >= 0,
                frame.maxY <= self.metalView.bounds.height {
                self.faceView.frame = frame
                self.orderSendWrap(frame)
                self.faceView.isHidden = false
            } else {
                print("faceView\(frame)")
              self.orderSendWrap()
                self.faceView.isHidden = true
            }
        }
        
        
    }
}
