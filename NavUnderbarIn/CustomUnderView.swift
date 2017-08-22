//
//  CustomUnderView.swift
//  NavUnderbarIn
//
//  Created by Admin on 22/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class CustomUnderView: B32UnderView {
    
    override func loadUnderviewFromNIB() -> UIView? {
        
        let customView = UIView()
        customView.backgroundColor = UIColor.blue
        
        let button = UIButton()
        button.setTitle("Tap me", for: .normal)
        
        customView.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        
        return customView
    }
}
