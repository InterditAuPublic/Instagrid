import Photos
import PhotosUI
import UIKit

typealias SetImageCallbackType = (_ image: UIImage) -> Void

class PhotoPicker: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePickerButton: UIButton?
    var setImageCallback: SetImageCallbackType?
    
    /// Set up and display Picker according to the ios Version of user
    func displayPicker(_ sender: UIButton, callback: @escaping SetImageCallbackType) { // check escaping

        imagePickerButton = sender
        setImageCallback = callback
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = PHPickerFilter.any(of: [.images])
            let photoPickerViewController = PHPickerViewController(configuration: config)
            photoPickerViewController.delegate = self
            present(photoPickerViewController, animated: true)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    /// PhotoPicker for iOS 14 and newer
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated:true) {
            guard !results.isEmpty else {
                return
            }
            
            for result in results { // replace by map or foreach
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
    
    /// UIImagePickerController for old iOS Versions
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let callback = setImageCallback else {
             dismiss(animated: true, completion: nil)
            return
        }
        callback(image)
        dismiss(animated: true, completion: nil)
    }
}
