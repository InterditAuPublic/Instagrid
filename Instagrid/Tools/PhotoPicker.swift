import Photos
import PhotosUI
import UIKit

typealias SetImageCallbackType = (_ image: UIImage) -> Void

class PhotoPicker: NSObject, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePickerButton: UIButton?
    var presentationController: UIViewController?
    var setImageCallback: SetImageCallbackType?
    
    /// Set up and display Picker according to the ios Version of user
    func displayPicker(_ sender: UIButton, presentationController: UIViewController, callback: @escaping SetImageCallbackType) {

        imagePickerButton = sender
        setImageCallback = callback
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = PHPickerFilter.any(of: [.images])
            let photoPickerViewController = PHPickerViewController(configuration: config)
            photoPickerViewController.delegate = self
            presentationController.present(photoPickerViewController, animated: true)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            presentationController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// PhotoPicker for iOS 14 and after
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated:true) {
            guard !results.isEmpty else {
                return
            }
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) {
                    [weak self]
                    object, error in
                    DispatchQueue.main.async { [self] in
                        guard let self = self, let image = object as? UIImage, let callback = self.setImageCallback else {
                            return
                        }
                        callback(image)
                    }
                }
            }
        }
    }
    
    /// UIImagePickerController for old iOS Versions (Before iOS 14)
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        presentationController?.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let callback = setImageCallback else {
            presentationController?.dismiss(animated: true, completion: nil)
            return
        }
        callback(image)
    }
}
