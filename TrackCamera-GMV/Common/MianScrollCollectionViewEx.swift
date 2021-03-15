


import UIKit
import AVFoundation


extension MainSceneViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.syncQueue.sync {
            self.semaphore.wait()
            self.cellDelegates = self.collectionView.visibleCells as? [ImageForFilterDelegate]
            let currentItem = self.collectionView.visibleCells[0]
            let index =  self.collectionView.indexPath(for: currentItem)
            print("当前位置AA\(String(describing: index))")
            
            if  filterItemsVideo.count > 0,(index != nil) {
                //            self.cameraWrap?.addFilter(type: filters[indexPath[1]])
                var temp:[FilterType] = defaultFilters
                if(!temp.contains(FilterType.none)){
                    temp.insert(FilterType.none, at: 0)
                }
                self.cameraWrap?.addFilter(type: temp[index![1]])
                //            cell.configure(filterName: temp[indexPath[1]].name())
                print("collectionView-真-当前滤镜\(temp[index![1]].name())")
                
                (currentItem as! FilteredCollectionCell).configure(filterName: temp[index![1]].name())
                
            }
            
            self.semaphore.signal()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("当前可见-didSelectItemAt\(indexPath)")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        if let cellForFilter = cell as? ImageForFilterDelegate {
        //            self.syncQueue.sync {
        //                self.semaphore.wait()
        //                let isHasAlready =  self.cellDelegates?.contains(where: { (item) -> Bool in
        //                    if(item.currentFilteredImage == cellForFilter.currentFilteredImage){
        //                        return true
        //                    }else{
        //                        return false
        //                    }
        //                })
        //                if(!isHasAlready!){
        //                    self.cellDelegates?.append(cellForFilter)
        //                }
        //                self.semaphore.signal()
        //            }
        //        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filteredCollectionCell", for: indexPath) as? FilteredCollectionCell else { fatalError("Wrong cell") }
        if filterItemsVideo.count > 0 {
            
            //            self.cameraWrap?.addFilter(type: filters[indexPath[1]])
            var temp:[FilterType] = defaultFilters
            if(!temp.contains(FilterType.none)){
                temp.insert(FilterType.none, at: 0)
            }
            self.cameraWrap?.addFilter(type: temp[indexPath[1]])
            cell.configure(filterName: temp[indexPath[1]].name())
            print("collectionView-当前滤镜\(temp[indexPath[1]].name())")
            
            //        cell.configure(filterName: Filters.type[indexPath[1]])
            
        }
        print("collectionView-当前位置A\(indexPath)")
        
    }
}
extension MainSceneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return Filters.type.count
        return defaultFilters.count + 1//无滤镜
        //        return (self.cameraWrap?.filterItems.count)!
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //会往后预加载一个
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filteredCollectionCell", for: indexPath) as? FilteredCollectionCell else { fatalError("Wrong cell") }
        //        cell.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        
        print("collectionView-当前位置AB\(indexPath)")
        
        //        cell.configure(filterName: Filters.type[indexPath[1]])
        //        cell.setNeedsLayout()
        
        return cell
    }
}

extension MainSceneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}


import Tweener
import Pow

//extension UIViewController {
extension UIView {
    
    public func alert() {
        
        var attributes: PowAttributes
        // Preset V
        attributes = .centerFloat
        attributes.windowLevel = .alerts
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.powInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: .dimmedLightBackground)
        attributes.powBackground = .color(color: .white)
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.border = .value(color: .black, width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5, offset: .zero))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        
        
        
        
        let attr = attributes
        // Generate textual content
        let title = PowProperty.LabelContent(text: "str_title".localize(), style: .init(font: MainFont.medium.with(size: 15), color: .black, alignment: .center))
        let description = PowProperty.LabelContent(text: "str_no_device".localize(), style: .init(font: MainFont.light.with(size: 13), color: .black, alignment: .center))
        let image = PowProperty.ImageContent(imageName: "tip", size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
        let simpleMessage = PowSimpleMessage(image: image, title: title, description: description)
        
        // Generate buttons content
        let buttonFont = MainFont.medium.with(size: 16)
        
        // Close button
        let closeButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Gray.a800)
        let closeButtonLabel = PowProperty.LabelContent(text: "str_retry".localize(), style: closeButtonLabelStyle)
        let closeButton = PowProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Gray.a800.withAlphaComponent(0.05)) {
            NotificationCenter.default.post(name: .SetRenewScan, object: false)
            
            Pow.dismiss()
        }
        
        //        // Remind me later Button
        //        let laterButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Teal.a600)
        //        let laterButtonLabel = PowProperty.LabelContent(text: "MAYBE LATER", style: laterButtonLabelStyle)
        //        let laterButton = PowProperty.ButtonContent(label: laterButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Teal.a600.withAlphaComponent(0.05)) {
        //            Pow.dismiss()
        //        }
        
        // Ok Button
        let okButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Teal.a600)
        let okButtonLabel = PowProperty.LabelContent(text: "str_close".localize(), style: okButtonLabelStyle)
        let okButton = PowProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Teal.a600.withAlphaComponent(0.05)) {
            Pow.dismiss()
        }
        
        // Generate the content
        let buttonsBarContent = PowProperty.ButtonBarContent(with: okButton, closeButton, separatorColor: PowColor.Gray.light, expandAnimatedly: true)
        
        let alertMessage = PowAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        // Setup the view itself
        let contentView = PowAlertMessageView(with: alertMessage)
        Pow.display(contentView, using: attr)
    }
    public func updateAlert(dismiss: @escaping (()->())) {
        
        var attributes: PowAttributes
        // Preset V
        attributes = .centerFloat
        attributes.windowLevel = .alerts
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.powInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: .dimmedLightBackground)
        attributes.powBackground = .color(color: .white)
        attributes.entranceAnimation = .init(scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.displayDuration = .infinity
        attributes.border = .value(color: .black, width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5, offset: .zero))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        
        
        
        
        let attr = attributes
        // Generate textual content
        let title = PowProperty.LabelContent(text: "str_title".localize(), style: .init(font: MainFont.medium.with(size: 15), color: .black, alignment: .center))
        let description = PowProperty.LabelContent(text: "str_update_content".localize(), style: .init(font: MainFont.light.with(size: 13), color: .black, alignment: .center))
        let image = PowProperty.ImageContent(imageName: "tip", size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
        let simpleMessage = PowSimpleMessage(image: image, title: title, description: description)
        
        // Generate buttons content
        let buttonFont = MainFont.medium.with(size: 16)
        
        // Close button
        let closeButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Gray.a800)
        let closeButtonLabel = PowProperty.LabelContent(text: "str_update_later".localize(), style: closeButtonLabelStyle)
        let closeButton = PowProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Gray.a800.withAlphaComponent(0.05)) {
            Pow.dismiss()
            dismiss()

        }
        
        //        // Remind me later Button
        //        let laterButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Teal.a600)
        //        let laterButtonLabel = PowProperty.LabelContent(text: "MAYBE LATER", style: laterButtonLabelStyle)
        //        let laterButton = PowProperty.ButtonContent(label: laterButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Teal.a600.withAlphaComponent(0.05)) {
        //            Pow.dismiss()
        //        }
        
        // Ok Button
        let okButtonLabelStyle = PowProperty.LabelStyle(font: buttonFont, color: PowColor.Teal.a600)
        let okButtonLabel = PowProperty.LabelContent(text: "str_update_ok".localize(), style: okButtonLabelStyle)
        let okButton = PowProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  PowColor.Teal.a600.withAlphaComponent(0.05)) {
            let url:NSURL = NSURL(string: "itms-apps://itunes.apple.com/cn/app/apai-go/id1522987792?mt=8")!
            UIApplication.shared.openURL(url as URL)
            Pow.dismiss()
            dismiss()

        }
        
        // Generate the content
        let buttonsBarContent = PowProperty.ButtonBarContent(with: okButton, closeButton, separatorColor: PowColor.Gray.light, expandAnimatedly: true)
        
        let alertMessage = PowAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        // Setup the view itself
        let contentView = PowAlertMessageView(with: alertMessage)
        Pow.display(contentView, using: attr)
    }
//color:PowColor.LightBlue.a700,
    public func popTopNotice(color:UIColor? = nil,tip:String? = nil){
        var tipCopy = "str_top_tip".localize()
        if(tip != nil){
            tipCopy = tip!
        }
        // Preset III
        var colorInner = PowColor.LightBlue.a700
        if(color != nil){
            colorInner = color!
        }
        
        var attributes: PowAttributes
        attributes = .topNote
        attributes.hapticFeedbackType = .error
        attributes.displayDuration = 3
        attributes.popBehavior = .animated(animation: .translation)
        attributes.powBackground = .color(color:colorInner )
        attributes.statusBarStyle = .lightContent
        let text = tipCopy
        let style = PowProperty.LabelStyle(font: MainFont.light.with(size: 14), color: .white, alignment: .center)
        let labelContent = PowProperty.LabelContent(text: text, style: style)
        let imageContent = PowProperty.ImageContent(imageName: "tip", size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
        
        let contentView = PowImageNoteMessageView(with: labelContent, imageContent: imageContent)
        
        Pow.display(contentView, using: attributes)
    }
    
    
    public func privacyDialog(isFirst:Bool) {
        //        Pow.display(NibExampleView(), using: attributes)
        var attributes: PowAttributes
        // Preset II
        attributes = .float
        attributes.windowLevel = .normal
        attributes.position = .center
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
        
        attributes.powInteraction = .absorbTouches
        if(isFirst){
            attributes.screenInteraction = .absorbTouches
            
        }else{
            attributes.screenInteraction = .dismiss
            
        }
        
        attributes.powBackground = .color(color: .white)
        attributes.screenBackground = .color(color: .dimmedDarkBackground)
        
        attributes.border = .value(color: UIColor(white: 0.6, alpha: 1), width: 1)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3, offset: .zero))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBarStyle = .lightContent
        
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 15, screenEdgeResistance: 0))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
        //      let v =  self.view.loadFromNib("PrivacyView")[0]
        //        let v = UIView.init(frame: self.view.frame)
        //        v.backgroundColor = UIColor.red;
        
        Pow.display(NibWebView(), using: attributes)
    }
    
    
    
    
}

