import UIKit

class LayoutView: UIButton {
    // Layout change according to the picker buttons display state
    
    @IBOutlet weak var TopRightButtonPicker: UIButton!
    @IBOutlet weak var BottomRightButtonPicker: UIButton!
    
    var currentStyle: LayoutStyle = .layout2 {
        didSet{
            setLayoutStyle(currentStyle)
        }
    }
    
    private func setLayoutStyle(_ LayoutStyle: LayoutStyle) {
        
        switch currentStyle {
            
        case .layout1:
            TopRightButtonPicker.isHidden = true
            BottomRightButtonPicker.isHidden = false
            
        case .layout2:
            TopRightButtonPicker.isHidden = false
            BottomRightButtonPicker.isHidden = true
        
        case .layout3:
            TopRightButtonPicker.isHidden = false
            BottomRightButtonPicker.isHidden = false
        }
    }
}
