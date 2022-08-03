import Photos
import PhotosUI
import UIKit

class ViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var layoutView: LayoutView!              /// Layout View
    @IBOutlet var imagePickerButtons: [UIButton]!           /// Array of four UIButton image
    @IBOutlet var changeDisplayLayoutButtons: [UIButton]!   /// Array of 3 buttons
    @IBOutlet weak var swipeStackView: UIStackView!         /// Swipe gesture for sharing layoutView
    
    // MARK: - Properties
    private let layoutDisplayStyle: [LayoutStyle] = [.layout1, .layout2, .layout3]
    private var imagePickerButton: UIButton?
    private var imageSelected: UIImage?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInterface()
    }
    
    // MARK: - viewDidLoad
    private func prepareInterface() {
        didPressedChangeLayoutButton(changeDisplayLayoutButtons[0])
        addShadowOnView()
        resetImagePickerButtons()
    }
    
    /// Add shadow to the layout
    private func addShadowOnView() {
        layoutView.layer.shadowColor = UIColor.black.cgColor
        layoutView.layer.shadowOpacity = 0.5
        layoutView.layer.shadowOffset = CGSize.zero
        layoutView.layer.shadowRadius = 3
    }
    
    private func resetImagePickerButtons() {
        for button in imagePickerButtons {
            button.setImage(#imageLiteral(resourceName: "Plus"), for: .normal)
        }
    }
   
    // MARK: Layout Buttons Actions
    @IBAction func didPressedChangeLayoutButton(_ sender: UIButton) {
        cleanLayoutButtons()
        selectedButton(button: sender)
        let tag = sender.tag
        layoutView.currentStyle = layoutDisplayStyle[tag]
    }
    
    ///Function that allows you to switch the button to selected mode
    private func selectedButton(button : UIButton) {
        button.isSelected = true
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    ///Function to clean buttons state
    private func cleanLayoutButtons() {
        for button in changeDisplayLayoutButtons {
            button.isSelected = false
        }
    }
    
//    MARK: Image Picker
    @IBAction func didPressImagePickerButton(_ sender: UIButton) {

        imagePickerButton = sender
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = PHPickerFilter.any(of: [.images])
            let photoPickerViewController = PHPickerViewController(configuration: config)
            photoPickerViewController.delegate = self
            present(photoPickerViewController, animated: true)
        } else {
            let photoSourceRequestController = UIAlertController(title: "", message: "Choose a picture ", preferredStyle: .actionSheet)
            let photoLibraryAlertAction = choiceSourceType(messageAlert: "Photo Library", sourceType: .camera)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            photoSourceRequestController.addAction(photoLibraryAlertAction)
            photoSourceRequestController.addAction(cancelAction)
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }

    /// PhotoPicker for iOS 14 and newer
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
                        guard let self = self else {
                            return
                        }
                        if let image = object as? UIImage {
                            self.imagePickerButton?.imageView?.contentMode = .scaleAspectFill
                            self.imagePickerButton?.setImage(image, for: .normal)
                        }
                    }
                }
            }
        }
    }

    private func choiceSourceType(messageAlert : String, sourceType : UIImagePickerController.SourceType ) -> UIAlertAction {
        let alertAction = UIAlertAction(title: messageAlert , style: .default) {(action ) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
        return alertAction
    }
        
    /// UIImagePicker for old iOS Versions
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePick = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage){
            imagePickerButton?.imageView?.contentMode = .scaleAspectFill
            imagePickerButton?.setImage(imagePick, for: .normal)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Swipe Action
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        presentActvitityUI()
        shareImageField()
    }
    
    private func presentActvitityUI() {
        guard let image = UIImage(systemName: "" ) else { return }
        let shareScreenVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareScreenVC, animated: true, completion: nil)
    }
    
    private func transformImageField(landScape : Bool) {
        let transform = landScape ? CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0) : CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
  
        UIView.animate(withDuration: 1.5) {
            self.layoutView.transform = transform
        } completion: { _ in
            UIView.animate(withDuration: 1.5) {
                self.prepareInterface()
                self.layoutView.transform = .identity
            }
        }
    }
    
    // MARK: - Share Image
    
    ///This function transforms the field into an image and displays the share sheet
    private func shareImageField() {
        let renderer = UIGraphicsImageRenderer(size: layoutView.bounds.size)
        let image = renderer.image { ctx in
            layoutView.drawHierarchy(in: layoutView.bounds, afterScreenUpdates: false)
        }
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: nil )
        viewController.popoverPresentationController?.sourceView = self.view
        viewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
        viewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            let alertUser = completed ? self.alertUser(title: "Sharing is a success", message: "Your action has been completed") : self.alertUser(title: "Sharing was not successful", message: "Your action failed or was canceled")
            self.present(alertUser, animated: true, completion: nil)
            if completed {
                self.cleanLayoutButtons()
            }
        }
        present(viewController, animated: true, completion: nil)
        transformImageField(landScape: true)
    }
    
    //This function create alert message
    private func alertUser(title : String , message : String) -> UIAlertController  {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            UIView.animate(withDuration: 3) {
                self.imagePickerButton?.transform = .identity
            }
        }))
        return alertVc
    }
}
