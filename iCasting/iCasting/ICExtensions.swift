//
//  ICExtensions.swift
//  iCasting
//
//  Created by T. van Steenoven on 21-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

enum ICDateFormat: String {
    case
    Matches = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'+'ss':'ss",
    News = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'000'Z'" //2015-01-31T23:00:00.000Z
}

extension String {
    
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
    
    public func makeRound(
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

