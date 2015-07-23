//
//  NSIndexPath+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// We create an extension of NSIndexPath to "inject" the cell identifiers to the specific indexPath which will be used by the tableview, don't forget to define a default cell type and value in your view controller: For every tableview, which needs specific reuse identifier, you can create an enum implementation with all the reuse identifiers which conforms to the Cells protocol and add it to the AbstractCellType enum.

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





// A struct that will hold all the cell properties, extend it to add functionality

struct CellProperties {
    
    let reuse: String
    let height: CGFloat
    
    init(reuse: String, height: CGFloat) {
        self.reuse = reuse
        self.height = height
    }
    init(reuse: String) {
        self.reuse = reuse
        self.height = 44
    }
}