//
//  CustomPhotoAlbum.swift
//  PhotoPicker
//
//  Created by Mac on 07.09.2018.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Photos
import MobileCoreServices
import UIKit

class CustomPhotoAlbum: NSObject {
    
    var albumName: String? = nil // here put your album name
    
    var photoAssets = PHFetchResult<PHAssetCollection>()
    var album: PHAssetCollection!
    
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.album = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    init(albumName: String) {
        super.init()
        self.albumName = albumName
    }
    
    init(albumID: String, completion: ((String?) -> Void)? = nil) {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum(with: albumID) {
            self.album = assetCollection
            self.albumName = self.album.localizedTitle
        } else {
            print("ERROR: CustomPhotoAlbum: can't get album with id = \(albumID)")
        }
        
        completion?(self.albumName)
        
    }
    
    func prepareAlbum(completion: @escaping (String) -> ()) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.album = assetCollection
            completion(self.album.localIdentifier)
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
            completion("")
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum(completion: completion)
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
            completion("")
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum(completion: @escaping (String) -> () = { _ in }) {
        
        guard let albumName = self.albumName else {
            completion("")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.album = self.fetchAssetCollectionForAlbum()
                completion(self.album.localIdentifier)
            } else {
                print("error \(error!)")
                completion("")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        
        guard let albumName = self.albumName else {
            return nil
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        photoAssets = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = photoAssets.firstObject {
            return photoAssets.firstObject
        }
        return nil
    }
    
    func fetchAssetCollectionForAlbum(with localIdentifier: String) -> PHAssetCollection? {
        photoAssets = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
        if let _: AnyObject = photoAssets.firstObject {
            return photoAssets.firstObject
        }
        return nil
    }
    
    func save(image: UIImageView) {
        if album == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            UIGraphicsBeginImageContextWithOptions(image.bounds.size, false, 0)
            let context: CGContext? = UIGraphicsGetCurrentContext()
            image.layer.render(in: context!)
            
            let imgs: UIImage? = image.image
            UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: imgs!)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.album)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler: nil)
    }
    
 
    
    func saveUImage(image: UIImage, completion: @escaping (String) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.album)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: { (success, error) -> Void in
            completion(success ? "Photo saved successfully" : error!.localizedDescription)
        })
    }
    
}
