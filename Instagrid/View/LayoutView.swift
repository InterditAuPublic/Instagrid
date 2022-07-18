//
//  Layouts.swift
//  Instagrid
//
//  Created by Melvin Mac on 06/07/2022.
//

import UIKit

class LayoutView: UIButton {
    // Layout depend of the isHidden property of 2 images
    
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
