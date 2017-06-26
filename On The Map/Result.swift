//
//  Result.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}
