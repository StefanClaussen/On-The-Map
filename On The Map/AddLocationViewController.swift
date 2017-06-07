//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 07/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func finishAddingLocation(_ sender: Any) {
        // Think in the completion handler, this is where the
        // logged in student's location will be sent to udacity server
        dismiss(animated: true, completion: nil)
    }

}
