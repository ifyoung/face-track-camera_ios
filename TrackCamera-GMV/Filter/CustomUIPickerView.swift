//
//  CustomUIPickerView.swift
//  LybiaApp
//
//  Created by MedBeji on 25/02/2018.
//  Copyright © 2018 unfpa. All rights reserved.
//

import UIKit
import Tweener

public typealias PickedAction = (Int)->Void

class CustomUIPickerView: UIPickerView,UIPickerViewDataSource, UIPickerViewDelegate {
    
    //    var model = [String]()
    //    var model = [FilterType]()
    var modelImage:[UIImage] = []{
        didSet {
            if  modelImage != oldValue {
                DispatchQueue.main.async {
                    self.setNeedsLayout()
                }
            }
        }
    }
    
    override var isHidden: Bool{
        didSet {
            if(isHidden){
                print("CustomUIPickerView-A显示\(isHidden)")
            }else{
                print("CustomUIPickerView-B显示\(isHidden)")
                
            }
        }
        
    }
    
    let semaphoreFilter = DispatchSemaphore(value: 1)
    
    var rotationAngle: CGFloat!
    
    var height:CGFloat = 60{
        didSet {
            if  height != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    var width:CGFloat = 60{
        didSet {
            if  width != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    var pickedActionVar:PickedAction?
    
    init(parentView:UIView,y: CGFloat = 0,selectedIndex: Int = 1) {
        super.init(frame: parentView.frame)
        setupPickerView(parentView,y, selectedIndex)
    }
    
    
    public func getPickedItem(ac:@escaping PickedAction){
        self.pickedActionVar = ac
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var filterName:[FilterType]!
    func setupPickerView(_ parentView:UIView,_ y: CGFloat,_ selectedIndex: Int){
        //        pickerView.widthComponent = self.view.frame.width
        self.delegate =  self
        self.dataSource = self
        self.transformToHorizontale()
        parentView.addSubview(self)
        
        //坐标控制弧度,300-600基本无弧度,200-400微
        self.frame = CGRect(x: 0-320, y: y+10, width: parentView.frame.width+600, height: height * 1.3)
        //        self.backgroundColor = UIColor.red
        self.selectRow(selectedIndex, inComponent: 0, animated: true)
        filterName = defaultFilters
               if(!filterName.contains(FilterType.none)){
                   filterName.insert(FilterType.none, at: 0)
               }
        self.clearSeparatorWithView()

    }
    
    
    //    var widthComponent: CGFloat?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modelImage.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return height
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return width
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width , height: height * 1.3)
        
        if(modelImage.count > 0){
            let image = modelImage[row]
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: height/3, width: width, height: height)
            imageView.contentMode = .scaleAspectFill
            
            
            let imageViewMask = UILabel.init(frame: CGRect(x: 0, y: height, width: width, height: height/3))
            imageViewMask.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            imageViewMask.text = filterName[row].name_zh()
            imageViewMask.font = UIFont.systemFont(ofSize: 12)
            imageViewMask.textColor = UIColor.black
            imageViewMask.textAlignment = .center
//            setTextLayer(centerStr: filterName[row].name_zh(), imgView: imageViewMask)

            view.addSubview(imageView)
            view.addSubview(imageViewMask)

            //        view.backgroundColor = UIColor.gray
            // view rotation
            view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
            
        }
        
        return view
    }
    
    
    func setTextLayer(centerStr:String,imgView:UIView){
        //字符蒙版
        let  txtMask = CATextLayer()
//                        txtMask.bounds = imgView.bounds //加上不显示
        txtMask.alignmentMode = CATextLayerAlignmentMode.center
        //        txtMask.anchorPoint = CGPoint(x: 0, y: 0)
//        txtMask.bounds.size = txtBounds.size
//        txtMask.bounds.size = imgView.bounds.size
//        txtMask.frame = imgView.frame
        txtMask.frame = CGRect.init(x: 0, y: imgView.bounds.size.height*2/3, width: imgView.bounds.size.width, height: imgView.bounds.size.height/3)
//        txtMask.position = center
        
        txtMask.contentsScale = UIScreen.main.scale
        txtMask.fontSize = 12
        txtMask.string = centerStr

        //            txtMask.contents = "progress_dialog_saving".localize()
        txtMask.foregroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        txtMask.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.6953392551)
        imgView.layer.addSublayer(txtMask)
    }
    
    var tempRow = 0
    //to do some stuff when row is selected, in our case we set picked image into our imageView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   let tempView = pickerView.view(forRow: row, forComponent: component)
   let tempViewByRow = pickerView.view(forRow: tempRow, forComponent: component)
        
        
        if let mask = tempView?.subviews[1] as? UILabel{
          let t = Tween(target:mask,//Target
                       duration:0.3,//One second
                                  ease:Ease.none,
                                  keys:[\UILabel.alpha:1,
                                        \UILabel.transform:mask.transform.translatedBy(x: 0, y:  -(mask.frame.width)),
//                                        \UILabel.textColor:UIColor.green,无用
                                        //This property is an optional.
                                      //                            \UIView.backgroundColor!:UIColor.red
                ])
            t.onComplete = {
                mask.textColor = Theme_COLOR
            }
            t.play()
          
        }

        if let maskTemp = tempViewByRow?.subviews[1] as? UILabel{
            if(tempRow != row){
              let r = Tween(target:maskTemp,//Target
                duration:0.3,//One second
                           ease:Ease.none,
                           keys:[\UILabel.alpha:1,
                                 \UILabel.transform:maskTemp.transform.translatedBy(x: 0, y:  (maskTemp.frame.width)),
//                                 \UILabel.textColor:UIColor.black,无用
                                 //This property is an optional.
                               //                            \UIView.backgroundColor!:UIColor.red
                    ])
                r.onComplete = {
                    maskTemp.textColor = UIColor.black
                }
                r.play()
                
            }
        }

        
        
        if let pickAction = self.pickedActionVar{
            pickAction(row)
        }
//        self.setNeedsLayout()
        tempRow = row

    }
    
    
    func transformToHorizontale(){
        rotationAngle = -90 * (.pi/180)
        self.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
}
