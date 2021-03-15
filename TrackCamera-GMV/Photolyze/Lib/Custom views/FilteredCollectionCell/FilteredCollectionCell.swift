//
//  FilteredCollectionCell.swift
//  Photolyze
//
//  Created by Mac on 05.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import CoreImage

protocol ImageForFilterDelegate {
    var currentFilteredImage: CIImage? { get set }
    func update(with image: CIImage)
    func updateDetection(with result: String,fps:String)
}

class FilteredCollectionCell: UICollectionViewCell {
    
    private let context = CIContext()
//    let queue = DispatchQueue(label: "com.custom.thread", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)//ios 10以前
//    let asyncQueue = DispatchQueue(label: "com.lammax.ios_\(Date())", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem)//iOS 10+
    
    let asyncQueue = DispatchQueue(label: "com.lammax.ios_\(Date())", qos: .userInitiated, attributes: .concurrent)
    
    
    private var filter: CIFilter?
    
    // MARK: ImageForFilterDelegate
    var currentFilteredImage: CIImage?
    var name:String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var metalView: VideoMetalView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(filterName: String?) {
        
        if let label = self.textLabel {
            name = filterName
            label.text = filterName
        }
        
        if let filterName = filterName {
//            self.filter = CIFilter(name: filterName)
        }
        self.layoutIfNeeded()

    }
    


}
//拓展更大
extension FilteredCollectionCell: ImageForFilterDelegate {
    func update(with image: CIImage) {
//        self.doFilterUsual(with: image)
        //self.doFilterMetal(with: image)
    }
    
    func updateDetection(with result: String, fps: String) {
        DispatchQueue.main.async {
            self.textLabel.text = result + ">>" + fps
        }
    }
    
}
