//
//  CellProperty.swift
//  iCasting
//
//  Created by Tim van Steenoven on 29/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

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

// This abstract cell property holds the higher group of cell identifiers for every table view that needs extended cell properties. You should add a case that points to the right CellIdentifier group which conforms to CellPropertyProtocol. The tableview controller needs specify the "defaultCellPropertyType" from the NSIndexPath extension to work with the right case

enum AbstractCellProperty: Int {
    case MatchDetailCells //, other cell types
    
    func getCellFromIdentifier(defaulCellIndex index: Int) -> CellIdentifierPropertyProtocol?  {
        switch self {
        case .MatchDetailCells:
            return CellIdentifier.MatchDetail.cells[index]
        }
    }
}