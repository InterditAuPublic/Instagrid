//
//  ViewController.swift
//  Instagrid
//
//  Created by Melvin Mac on 16/05/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton?
    
    @IBOutlet weak var button2: UIButton?
    
    @IBOutlet weak var button3: UIButton?
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func button1Pressed(_ sender: UIButton) {
        sender.isSelected = true
        print("Button 1 pressé")
    }
    
    @IBAction func button2Pressed(_ sender: UIButton) {
        sender.isSelected = true
        print("Button 2 pressé")
    }
    
    @IBAction func button3Pressed(_ sender: UIButton) {
        sender.isSelected = true
        print("Button 3 pressé")
    }
}

