//
//  ImagePicker.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/20.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import Foundation
import Photos

struct PickedImage {
    private(set) var fileURLString: String
    private(set) var name: String
    private(set) var image: UIImage
}

protocol ImagePickerControllerDelegate: class {
    func imagePickerDidPickedImage(_ image: PickedImage)
}

class ImagePickerController: NSObject {
    
    weak var delegate: ImagePickerControllerDelegate?
    private weak var fromController = UIViewController()
    fileprivate var pickedImageName: String {
        return "UserIcon" + String(Int(Date().timeIntervalSince1970 / 1000))
    }
    
    private var photoAction: UIAlertAction {
        return UIAlertAction(title: R.string.localizable.common_photo_library(), style: .default, handler: { (action) in
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.presentImagePickerController(sourceType: .photoLibrary)
            }
        })
    }
    
    private var cameraAction: UIAlertAction {
        return UIAlertAction(title: R.string.localizable.common_camera(), style: .default, handler: { (action) in
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if status == .authorized {
                self.presentImagePickerController(sourceType: .camera)
            }
        })
    }
    
    func present(from: UIViewController, delegate: ImagePickerControllerDelegate?, popoverSourceViewForIPad: UIView? = nil) {
        self.delegate = delegate
        fromController = from
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .denied {
                DispatchQueue.main.async(execute: {
                    BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.no_permission_album_go_settings())
                })
                return
            }
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        guard self.isPhotoLibraryAvailable() || self.isCameraLibraryAvailable() else {
            return
        }
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        alertController.addAction(UIAlertAction(title: R.string.localizable.common_cancel(), style: .cancel, handler: nil))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let popover = alertController.popoverPresentationController
            popover?.sourceView = popoverSourceViewForIPad
            popover?.sourceRect = (popoverSourceViewForIPad?.bounds)!
        }
        from .present(alertController, animated: true, completion: nil)
    }
    
    private func isCameraLibraryAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isCameraDeviceAvailable(.rear) && UIImagePickerController.isCameraDeviceAvailable(.front)
    }
    
    private func isPhotoLibraryAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    fileprivate func scaleImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(targetSize)
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        return scaledImage
    }
    
    fileprivate func scaledImageFileURL(_ image: UIImage, name: String) -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString
        let filePath = cachePath.appendingPathComponent(name)
        let imageData = UIImagePNGRepresentation(image) as NSData?
        imageData?.write(toFile: filePath, atomically: true)
        return filePath
    }
    
    private func presentImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        fromController?.present(imagePickerController, animated: true, completion: nil)
    }
}

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let scaledImage = scaleImage(info[UIImagePickerControllerEditedImage] as! UIImage, targetSize: CGSize(width: 110, height: 110))
        let imageName = pickedImageName
        let fileURL = scaledImageFileURL(scaledImage, name: imageName)
        let pickedImage = PickedImage(fileURLString: fileURL, name: imageName, image: scaledImage)
        picker.dismiss(animated: true) {
            guard let delegate = self.delegate else { return }
            delegate.imagePickerDidPickedImage(pickedImage)
        }
    }
}
