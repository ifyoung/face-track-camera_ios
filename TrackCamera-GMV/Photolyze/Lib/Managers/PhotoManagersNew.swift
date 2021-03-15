//
//  PhotoManagers.swift
//  lc_facecamera
//
//  Created by LCh on 2020/5/30.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import Photos

@objc protocol PhotoManagersDelegateNew {
    @objc  func getLatestImg(image: UIImage?)
}

class PhotoManagersNew: NSObject {
    typealias GetLatestImg = ((UIImage?) -> Void)
    
    
    var delegate: PhotoManagersDelegateNew?
    
    
    //取得的资源结果，用来存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>!
    //取得的资源结果，用来存放的PHAsset
    var photoCollections = [DLPhotoCollection]()
    //用于显示缩略图
    var imageLatest: UIImage!
    
    var latestImgListener:GetLatestImg?
    
    var isChanged = false
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    var change_detection_Queue = DispatchQueue.init(label: "change_detection_Queue")
    
    
    
    //传入要显示的缩略图大小
    init(frame:CGRect) {
        super.init()
        //imageView初始化
        //        imageView = UIImageView()
        //        imageView.frame = CGRect(x:20, y:40, width:100, height:100)
        //        imageView.contentMode = .scaleAspectFill
        //        imageView.clipsToBounds = true
        //        self.view.addSubview(imageView)
        
        //初始化和重置缓存
        //        self.imageManager = PHCachingImageManager()
        //计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        assetGridThumbnailSize = CGSize(width: frame.width*scale ,
                                        height: frame.height*scale)
        
        DLPhotoManager.sharedInstance()?.fetchPhotoCollection({ (isSuccess) in
            if(isSuccess){
                self.photoCollections = DLPhotoManager.sharedInstance()?.photoCollections as! [DLPhotoCollection]
            }
        })
        
        //监听资源改变
        //        PHPhotoLibrary.shared().register(self)
        DLPhotoManager.sharedInstance()?.register(self)
        //        })
    }
    
    public  func notifyPosterImg(){
        if(self.photoCollections.count > 0){
            let imgs = DLPhotoManager.sharedInstance()?.posterImages(for: self.photoCollections[0], thumbnailSize: self.assetGridThumbnailSize, count: 1)
            //放初始化里会先于代理初始化赋值
            self.delegate?.getLatestImg(image: imgs![0] as? UIImage)
        }
    }
    
    public func getLatestImg(ac:@escaping GetLatestImg){
        self.latestImgListener = ac
    }
    
    
    
    deinit {
        
        //        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        DLPhotoManager.sharedInstance()?.unregisterChangeObserver(self)
        
    }
    
    var isIndelay = false
    
}

//PHPhotoLibraryChangeObserver代理实现，图片新增、删除、修改开始后会触发
extension PhotoManagersNew:PHPhotoLibraryChangeObserver{
    
    
    
    
    //当照片库发生变化的时候会触发,一次变动触发多次？
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        //获取assetsFetchResults的所有变化情况，以及assetsFetchResults的成员变化前后的数据
        //        guard let collectionChanges = changeInstance.changeDetails(for:
        //            self.assetsFetchResults as! PHFetchResult<PHObject>) else { return }
        if(isIndelay){//防止瞬间多次刷新
            return
        }
        self.isIndelay = true
        self.change_detection_Queue.asyncAfter(deadline: DispatchTime.now()+0.7) {
            //刷新
            DLPhotoManager.sharedInstance()?.fetchPhotoCollection({ (isSuccess) in
                if(isSuccess){
                    self.photoCollections = DLPhotoManager.sharedInstance()?.photoCollections as! [DLPhotoCollection]
                    self.notifyPosterImg()
                    print("--- 执行刷新 ---\(changeInstance.description)--\(changeInstance.hash)")
                    self.isIndelay = false
                }
            })
            self.isIndelay = false//??
        }
        
        //获取最新的完整数据
        print("--- 监听到变化 ---\(changeInstance.description)--\(changeInstance.hash)")
        //            DLPhotoManager.sharedInstance()?.unregisterChangeObserver(self)
        
        
    }
}
