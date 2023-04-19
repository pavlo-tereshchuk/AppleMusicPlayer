//
//  Extensions.swift
//  tabBar
//
//  Created by Pavlo Tereshchuk on 19.04.23.
//

import Foundation

extension TimeInterval {
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}
