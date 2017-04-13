//
//  UIColor+Custom.swift
//  333
//
//  Created by Sarah Zhou on 4/13/17.
//  Copyright © 2017 333. All rights reserved.
//

import Swift
import UIKit

extension UIColor {
    
    class func fromRgbHex(_ fromHex: Int) -> UIColor {
        
        let red = CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func ourBlue() -> UIColor {
        let color = 0x5EB1E4
        return UIColor.fromRgbHex(color)
    }
    
    class func ourGray() -> UIColor {
        let color = 0x95a5a6
        return UIColor.fromRgbHex(color)
    }
    
    class func clouds() -> UIColor {
        let color = 0xecf0f1
        return UIColor.fromRgbHex(color)
    }
}
