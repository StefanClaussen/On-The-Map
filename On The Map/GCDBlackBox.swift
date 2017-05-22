//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Stefan Claussen on 22/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
