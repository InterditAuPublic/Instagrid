import Photos
import PhotosUI
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var layoutView: LayoutView! /// Layout View
    @IBOutlet var imagePickerButtons: [UIButton]!           /// Array of four UIButton image
    @IBOutlet var changeDisplayLayoutButtons: [UIButton]!   /// Array of 3 buttons
    @IBOutlet weak var swipeStackView: UIStackView!
    @IBOutlet weak var swipeArrowView: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var applicationTitle: UILabel!
    @IBOutlet weak var layoutRatioConstraint: NSLayoutConstraint!
    
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
        prepareLabels()
        prepareSwipeGesture()
        selectedButton(button: changeDisplayLayoutButtons[0])
        layoutView.currentStyle = layoutDisplayStyle[1]
        addShadowOnView()
        resetImagePickerButtons()
    }
    
    private func prepareLabels() {
        guard let delmMedium = UIFont(name: "Delm-Medium", size: 22) else {
            print("Unable to load \"Delm-Medium\" font.")
            return

        }
        guard let thirstySoftRegular = UIFont(name: "ThirstySoftRegular", size: 28) else {
            print("Unable to load \"ThirstySoftRegular\" font.")
            return
        }
                       
        applicationTitle.text = "Instagrid"
        applicationTitle.font = UIFontMetrics.default.scaledFont(for: thirstySoftRegular)
        
        swipeLabel.font = UIFontMetrics.default.scaledFont(for: delmMedium)
        swipeLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func prepareSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .up
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .left
        layoutView.addGestureRecognizer(swipeUp)
        layoutView.addGestureRecognizer(swipeLeft)
        swipeUp.addTarget(self, action: #selector(didSwipe))
        swipeLeft.addTarget(self, action: #selector(didSwipe))
    }
    
    /// Add shadow to the layout
    private func addShadowOnView() {
        layoutView.layer.shadowColor = UIColor.black.cgColor
        layoutView.layer.shadowOpacity = Constants.Shadow.opacity
        layoutView.layer.shadowOffset = CGSize.zero
        layoutView.layer.shadowRadius = Constants.Shadow.radius
    }
    
    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.layoutRatioConstraint.priority = .defaultHigh
            UIView.animate(withDuration:0.15) {
                self.layoutView.alpha = 0
            }
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            self.layoutRatioConstraint.priority = .required
            UIView.animate(withDuration:0.15) {
                self.layoutView.alpha = 1
            }
            return
        }
    }
    
    private func resetImagePickerButtons() {
        for button in imagePickerButtons {
            button.setImage(#imageLiteral(resourceName: "Plus-1"), for: .normal)
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
    
    @objc private func didSwipe(sender: UISwipeGestureRecognizer) {
        let positionPortrait : Bool = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        
        switch sender.direction {
        case .left:
            if UIDevice.current.orientation.isLandscape || !positionPortrait{
                print(sender.direction)
                transformImageField(landscape: true)
            }
        default:
            if positionPortrait {
                print(sender.direction)
                transformImageField(landscape: false)
            }
        }
    }

    private func transformImageField(landscape : Bool) {
        let transform = landscape ? CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0) : CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let durationTime = Constants.Animation.duration
        
        UIView.animate(withDuration: durationTime) {
            self.layoutView.transform = transform
            self.shareImageField()
        } completion: { _ in
            UIView.animate(withDuration: durationTime) {
                self.cleanLayoutButtons()
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
                print("fini")
            }
        }
        present(viewController, animated: true, completion: nil)
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
