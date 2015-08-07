//
//  NSIndexPath+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// We create an extension of NSIndexPath to "inject" the cell identifiers to the specific indexPath which will be used by the tableview, don't forget to define a default cell type and value in your view controller: For every tableview, that needs specific reuse identifiers, you can create an enum implementation with all the reuse identifiers which conforms to the CellPropertyProtocol and add it to the AbstractCellType enum.

extension NSIndexPath {
    
    static var defaultCellPropertyType: AbstractCellProperty = AbstractCellProperty(rawValue: 0)!
    static var defaultCellIndex: Int? = 0
    
    // The cell identifier is binded to the indexPath, it will get the right properties depending on the section and row defined in the CellPropertyProtocol
    var cellIdentifier: CellIdentifierPropertyProtocol {
        
        get {
            // Bundle the section and row so it can match the enumeration cell type raw int value
            let index = ("\(self.section)"+"\(self.row)").toInt()!
            
            // Get the default CellPropertyProtocol from the AbstractCellPropertyType, change this in the view controller through the static property
            var type: AbstractCellProperty = NSIndexPath.defaultCellPropertyType

            // Get the right cell enumeration if it exist with the index, otherwise get the default
            var cell: CellIdentifierPropertyProtocol = type.getCellFromIdentifier(defaulCellIndex: NSIndexPath.defaultCellIndex!)!
            if let c: CellIdentifierPropertyProtocol = type.getCellFromIdentifier(defaulCellIndex: index) {
                cell = c
            }
            return cell
        }
    }
}