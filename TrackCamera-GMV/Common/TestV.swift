import UIKit
import Photos

class TestV: UIViewController {
    
    //取得的资源结果，用来存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>!
    
    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    //用于显示缩略图
    var imageView: UIImageView!
    
    //缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    override func viewDidLoad() {
        //imageView初始化
        imageView = UIImageView()
        imageView.frame = CGRect(x:20, y:40, width:100, height:100)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        
        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        
        //计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        assetGridThumbnailSize = CGSize(width: imageView.frame.width*scale ,
                                        height: imageView.frame.height*scale)
        
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            //启动后先获取目前所有照片资源
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                     PHAssetMediaType.image.rawValue)
            self.assetsFetchResults = PHAsset.fetchAssets(with: .image,
                                                          options: allPhotosOptions)
            print("--- 资源获取完毕 ---")
            
            //获取最后添加的图片资源
            let asset = self.assetsFetchResults[0]
            //获取缩略图
            self.imageManager.requestImage(for: asset,
                                           targetSize: self.assetGridThumbnailSize,
                                           contentMode: .aspectFill, options: nil) {
                                            (image, nfo) in
                                            DispatchQueue.main.async {
                                                self.imageView.image = image
                                                
                                            }
            }
            
            //监听资源改变
            PHPhotoLibrary.shared().register(self)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//PHPhotoLibraryChangeObserver代理实现，图片新增、删除、修改开始后会触发
extension TestV:PHPhotoLibraryChangeObserver{
    
    //当照片库发生变化的时候会触发
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("--- 监听到变化-test ---")

        //获取assetsFetchResults的所有变化情况，以及assetsFetchResults的成员变化前后的数据
        guard let collectionChanges = changeInstance.changeDetails(for:
            self.assetsFetchResults as! PHFetchResult<PHObject>) else { return }
        
        DispatchQueue.main.async {
            //获取最新的完整数据
            if let allResult = collectionChanges.fetchResultAfterChanges
                as? PHFetchResult<PHAsset>{
                self.assetsFetchResults = allResult
            }
            
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves{
                return
            }else{
                //照片删除情况
                if let removedIndexes = collectionChanges.removedIndexes,
                    removedIndexes.count > 0{
                    print("删除了\(removedIndexes.count)张照片")
                }
                //照片修改情况
                if let changedIndexes = collectionChanges.changedIndexes,
                    changedIndexes.count > 0{
                    print("修改了\(changedIndexes.count)张照片")
                }
                //照片新增情况
                if let insertedIndexes = collectionChanges.insertedIndexes,
                    insertedIndexes.count > 0{
                    print("新增了\(insertedIndexes.count)张照片")
                    print("将最新一张照片的缩略图显示在界面上。")
                    
                    //获取最后添加的图片资源
                    let asset = self.assetsFetchResults[insertedIndexes.first!]
                    //获取缩略图
                    self.imageManager.requestImage(for: asset,
                                                   targetSize: self.assetGridThumbnailSize,
                                                   contentMode: .aspectFill, options: nil) {
                                                    (image, nfo) in
                                                    self.imageView.image = image
                    }
                }
            }
        }
    }
}
