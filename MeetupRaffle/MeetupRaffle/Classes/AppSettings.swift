//
//  AppSettings.swift
//  MeetupRaffle
//
//  Created by Antoine van der Lee on 11/02/17.
//  Copyright © 2017 alee. All rights reserved.
//

import Foundation
import UIKit

struct AppSettings {
    
    struct Colors {
        static let primaryBackground = UIColor(hex: "#222222")
        static let primaryText = UIColor.white
        static let buttonText = UIColor(hex: "#FEC503")
    }
    
    // E.g. https://www.meetup.com/CocoaHeadsNL/events/235990222/
    // Groupname: CocoaHeadsNL
    // Event ID: 235990222
    struct Meetup {
        static let name = "Februari @ Xebia" // This can be random
        static let group = "CocoaHeadsNL"
        static let eventId = 235990222
    }
    
    // These can be copied from: https://secure.meetup.com/meetup_api/console/?path=/:urlname/events/:event_id/rsvps
    // Just try the call and copy from the signed URL
    struct APISettings {
        static let sigId = 187030538
        static let sig = "5dbcabc13b7f0d4030da866b1c1136a2f84e42d9"
        
    }
}

extension UIColor {
    
    /// You can pass a hex with or without # and with or without alpha
    convenience init(hex: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: cleanHex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            if cleanHex.characters.count == 6 {
                red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                blue  = CGFloat(hexValue & 0x0000FF) / 255.0
            } else if cleanHex.characters.count == 8 {
                alpha   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                red = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                green  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                blue = CGFloat(hexValue & 0x000000FF)         / 255.0
            } else {
                print("invalid rgb string, length should be 6 or 8", terminator: "")
            }
        } else {
            print("scan hex error")
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
