//
//  Utils.swift
//  333
//
//  Created by Victor Zhou on 4/22/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation

class Utils {
    static let dateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return df
    }()
    
    static let niceDateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "MM-dd hh:mm"
        return df
    }()
}
