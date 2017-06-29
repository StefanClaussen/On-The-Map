//
//  UIButton+CornerRadius.swift
//  On The Map
//
//  Created by Stefan Claussen on 29/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

extension UIButton {
    
    var cornerRadius: Bool {
        get { fatalError("Corner radius is set only") }
        set { adjustCornerRadius() }
    }
    
    func adjustCornerRadius() {
        layer.cornerRadius = 4.0
    }
}
