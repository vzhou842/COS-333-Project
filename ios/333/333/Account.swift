//
//  Account.swift
//  333
//
//  Created by Andre Xiong on 5/9/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import Foundation

class Account {
    static let sharedInstance = Account()
    private init() {}
    var user_id = UIDevice.current.identifierForVendor!.uuidString
}
