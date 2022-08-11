import Photos
import PhotosUI
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!   /// Swipe gesture for sharing layoutView
    @IBOutlet weak var layoutView: LayoutView!              /// Layout View
    @IBOutlet var imagePickerButtons: [UIButton]!           /// Array of four UIButton image
    @IBOutlet var changeDisplayLayoutButtons: [UIButton]!   /// Array of 3 buttons
    @IBOutlet weak var swipeStackView: UIStackView!
    
    // MARK: - Properties
    private let layoutDisplayStyle: [LayoutStyle] = [.layout1, .layout2, .layout3]
    private var imagePickerButton: UIButton?
    private var imageSelected: UIImage?
    private let photoPicker = PhotoPicker()
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInterface()
    }
    
    // MARK: - PrepareInterface
    private func prepareInterface() {
        selectedButton(button: changeDisplayLayoutButtons[0])
        layoutView.currentStyle = layoutDisplayStyle[1]
        addShadowOnView()
        resetImagePickerButtons()
    }
    
    /// Add shadow to the layout
    private func addShadowOnView() {
        layoutView.layer.shadowColor = UIColor.black.cgColor
        layoutView.layer.shadowOpacity = Constants.Shadow.opacity
        layoutView.layer.shadowOffset = CGSize.zero
        layoutView.layer.shadowRadius = Constants.Shadow.radius
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
    
//    MARK: Image Picker Buttons
    @IBAction func didPressImagePickerButton(_ sender: UIButton) {
        
        imagePickerButton = sender
        
        photoPicker.displayPicker(sender, presentationController: self) { image in
            guard let pickerButton = self.imagePickerButton else {
                return
            }
            pickerButton.imageView?.contentMode = .scaleAspectFill
            pickerButton.setImage(image, for: .normal)
        }
    }

    // MARK: Swipe Action
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        presentActvitityUI()
        shareImageField()
        
        let positionPortrait : Bool = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        
        switch sender.direction {
        case .left:
            if UIDevice.current.orientation.isLandscape || !positionPortrait{
                transformImageField(landscape: true)
            }
        default:
            if positionPortrait {
                transformImageField(landscape: false)
            }
        }
    }
    
    private func presentActvitityUI() {
        guard let image = UIImage(systemName: "" ) else { return }
        let shareScreenVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareScreenVC, animated: true, completion: nil)
    }
    
    private func transformImageField(landscape : Bool) {
        let transform = landscape ? CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0) : CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let durationTime = Constants.Animation.duration
        UIView.animate(withDuration: durationTime) {
            self.layoutView.transform = transform
        } completion: { _ in
            UIView.animate(withDuration: durationTime) {
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
            let alertUser = completed ? self.alertUser(title: "Sharing is a success", message: "Your action has been completed.") : self.alertUser(title: "Sharing didn't complete", message: "Your action failed or has been canceled.")
            self.present(alertUser, animated: true, completion: nil)
            if completed {
                self.cleanLayoutButtons()
            }
        }
        present(viewController, animated: true, completion: nil)
        
//        if UIDevice.current.orientation.isLandscape {
//            transformImageField(landscape: true)
//        } else {
//            transformImageField(landscape: false)
//        }
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
