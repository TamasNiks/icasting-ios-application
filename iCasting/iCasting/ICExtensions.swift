//
//  ICExtensions.swift
//  iCasting
//
//  Created by T. van Steenoven on 21-04-15.
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
    
    // Color to add details interface elements on default red
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
}


extension String {

    enum ICDateFormat: String {
        case
        General = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'+'ss':'ss",
        News = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'000'Z'" //2015-01-31T23:00:00.000Z
    }
    
    func ICdateToString(format: ICDateFormat) -> String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format.rawValue
        
        if let date: NSDate = dateFormatter.dateFromString(self) {
            
            let visibleFormatter = NSDateFormatter()
            visibleFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            visibleFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            return visibleFormatter.stringFromDate(date)
        }
        
        return nil
    }
    
    func ICTime() -> String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH':'mm"
        
        if let date: NSDate = dateFormatter.dateFromString(self) {
            
            let visibleFormatter = NSDateFormatter()
            visibleFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            visibleFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            return visibleFormatter.stringFromDate(date)
        }
        
        return nil
        
    }
}


extension UIImageView {
    
    func makeRound(
        amount:CGFloat,
        borderWidth withBorderWidth: CGFloat? = 2.0,
        withBorderColor:UIColor = UIColor(white: 1.0, alpha: 1.0)) {

        self.layer.cornerRadius = amount
        self.clipsToBounds = true
        self.layer.frame = CGRectInset(self.layer.frame, 20, 20)
        
        if let bw = withBorderWidth {
            self.layer.borderColor = withBorderColor.CGColor
            self.layer.borderWidth = bw
        }

    }
    
}


extension UITableView {
    
    // Define the left padding through white spaces, check https://www.cs.tut.fi/~jkorpela/chars/spaces.html
    
    func setTableHeaderViewWithoutResults(text: String) {
        
        var label: UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, 90))
        label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        label.text = "\u{2003}"+text+"\u{2002}"
        label.textAlignment = NSTextAlignment.Center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        self.tableHeaderView = label
    }

    func setTableHeaderViewWithResults(text: String) {
        
        var label: UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width, 35))
        label.backgroundColor = UIColor.ICDarkenedRedColor() //UIColor(red: 172/255, green: 9/255, blue: 33/255, alpha: 1.0)
        label.textColor = UIColor.whiteColor()
        label.text = "\u{2003}"+text+"\u{2002}"
        label.textAlignment = NSTextAlignment.Center
        label.adjustsFontSizeToFitWidth = true
        self.tableHeaderView = label
    }
    
    
    func setWholeSeperatorLines() {
        
        if self.respondsToSelector("setSeparatorInset:") {
            self.separatorInset = UIEdgeInsetsZero
        }
        if self.respondsToSelector("setLayoutMargins:") {
            self.layoutMargins = UIEdgeInsetsZero
        }
        self.layoutIfNeeded()
    }
    
}


extension UITableViewCell {
    
    func calculateHeight() -> CGFloat {
        let size: CGSize = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
    
}

// We create an extension of NSIndexPath to "inject" the cell identifiers to the specific indexPath which will be used by the tableview, don't forget to define a default cell type and value in your view controller: For every tableview, which needs specific reuse identifier, you can create an enum implementation with all the reuse identifiers which conforms to the Cells protocol and add it to the AbstractCellType enum.

protocol CellsProtocol {
    var properties: CellProperties {get}
}

enum AbstractCellsType: Int {
    case matchCells = 0 //, other cell types
    
    func rawValue(value: Int) -> CellsProtocol?  {
        switch self {
        case .matchCells:
            return MatchCells(rawValue: value)
        }
    }
}


extension NSIndexPath {
    
    static var defaultCellType: AbstractCellsType = AbstractCellsType(rawValue: 0)!
    static var defaultCellValue: Int? = 0
    
    var cellIdentifier: CellsProtocol {
        
        get {
            // Bundle the section and row so it can match the enumeration cell type raw int value
            let index: Int = ("\(self.section)"+"\(self.row)").toInt()!
            var cellType: AbstractCellsType = NSIndexPath.defaultCellType
            var cellValue: Int = NSIndexPath.defaultCellValue!
            
            var _cell: CellsProtocol = cellType.rawValue(cellValue)!
            if let c: CellsProtocol = cellType.rawValue(index) {
                _cell = c
            }
            return _cell
        }
    }
}


extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        
        get {
            return UIColor(CGColor: layer.borderColor)
        }
        
        set {
            layer.borderColor = newValue?.CGColor
        }
        
    }
    
    
    @IBInspectable var borderWidth: CGFloat {
        
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
        
    }
    
    @IBInspectable var cornerRadius: CGFloat {
    
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    
    }
    
}



// A struct that will hold all the cell properties, extend it to add functionality

struct CellProperties {
    
    let reuse: String
    let height: CGFloat
    
    init(reuse: String, height: CGFloat) {
        self.reuse = reuse
        self.height = height
    }
    init(_ reuse: String) {
        self.reuse = reuse
        self.height = 44
    }
}

