//
//  Utils.swift
//  333
//
//  Created by Victor Zhou on 4/22/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation
import MapKit

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
    
    static func formatDate(_ number: TimeInterval) -> String {
        var formatted = ""
        
        if number < 60 {
            formatted = String(format: "%.0f", Double(number)) + "s"
        } else if number < 3600 {
            formatted = String(format: "%.0f", Double(number) / 60.0) + "m"
        } else if number < 86400 {
            formatted = String(format: "%.0f", Double(number) / 3600.0) + "h"
        } else if number < 2073600 {
            formatted = String(format: "%.0f", Double(number) / 86400.0) + "d"
        }
        
        return formatted
    }
}
