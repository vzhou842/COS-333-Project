//
//  Toaster.swift
//  333
//
//  Created by Victor Zhou on 5/8/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation
import Toast_Swift

class Toaster {
    static let style: ToastStyle = {
        var style = ToastStyle()
        style.messageFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        return style
    }()

    static func makeToastBottom(_ view: UIView, _ message: String) {
        ToastManager.shared.queueEnabled = false
        view.makeToast(message, duration: 2.0, position: ToastPosition.bottom, style: style)
    }
    
    static func makeToastTop(_ view: UIView, _ message: String) {
        ToastManager.shared.queueEnabled = false
        view.makeToast(message, duration: 2.0, position: ToastPosition.top, style: style)
    }
}
