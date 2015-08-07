//
//  UIColor+ICColors.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

extension UIColor {
    
    // Main interface color
    class func ICRedDefaultColor() -> UIColor {
        return UIColor(red: 223/255, green: 31/255, blue: 54/255, alpha: 1.0)
    }
    
    // Color for emphasize on default red
    class func ICDarkenedRedColor() -> UIColor {
        return UIColor(red: 190/255, green: 28/255, blue: 47/255, alpha: 1.0)
    }
    
    // Color to add details interface elements on default redD
    class func ICShadowRedColor() -> UIColor {
        return UIColor(red: 201/255, green: 27/255, blue: 48/255, alpha: 1.0)
    }
    
    // Color for footer
    class func ICDarkGrayColor() -> UIColor {
        return UIColor(red: 75/255, green: 73/255, blue: 75/255, alpha: 1.0)
    }
    
    // Color for header backgrounds
    class func ICLightGrayColor() -> UIColor {
        return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
    }
    
    // Color for buttons
    class func ICGreenColor() -> UIColor {
        return UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    }
    
    // Color for header text
    class func ICTextDarkGrayColor() -> UIColor {
        return UIColor(white: 77/255, alpha: 1.0) //UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
    }
    
    // Color for main text
    class func ICTextLightGrayColor() -> UIColor {
        return UIColor(white: 138/255, alpha: 1.0) //UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)
    }
    
    //Color for dilemma buttons
    class func ICRedDilemmaColor() -> UIColor {
        return UIColor(red: 223.rgb, green: 50.rgb, blue: 54.rgb, alpha: 1)
    }
    
    //Color for dilemma buttons
    class func ICGreenDilemmaColor() -> UIColor {
        return UIColor(red: 46.rgb, green: 204.rgb, blue: 113.rgb, alpha: 1)
    }
}