//
//  SizingCellProvider.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit


class SizingCellProvider {
    
    private var tableView: UITableView?
    static var sizingTokens: [String : dispatch_once_t] = [String : dispatch_once_t]()
    static var sizingCells: [String : UITableViewCell] = [String : UITableViewCell]()
    
    init(tableView: UITableView) {
        
        self.tableView = tableView
    }
    
    typealias CellDataProviderType = (cell: UITableViewCell)->()
    
    
    func heightForCustomCell(fromIdentifier identifier: CellIdentifier, calculatorType: CellHeightCalculatorType, dataProvider: CellDataProviderType) -> CGFloat {
        
        
        // Intialize tokens for the dispatch_once function and grap the cell for one time only in the lifetime of the app
        
        initToken(identifier.rawValue)
        
        dispatch_once(&SizingCellProvider.sizingTokens[identifier.rawValue]!) {
            let cell = self.tableView!.dequeueReusableCellWithIdentifier(identifier.rawValue) as? UITableViewCell
            SizingCellProvider.sizingCells[identifier.rawValue] = cell
        }
        
        
        // First fill the cell with necessary sizing data like strings.
        
        let cell = provideCellWithDataForSizing(identifier.rawValue, dataProvider: dataProvider)
        

        // Then grab a calculator based on the specified cell height calculator type. Typically this will be a standard cell or a custom cell with constraints. Either way, the cell needs to be prepared before using a calculator. To use the AutoLayout calculator, add constraints to the contentView of the cell.
       
        var calc: CellHeightCalculator = CellHeightCalculatorFactory.getCalculator(type: calculatorType)
        
        let height = calc.calculateHeight(cell)

        return height
    }
    
    
    private func provideCellWithDataForSizing(identifier: String, dataProvider: CellDataProviderType) -> UITableViewCell {
        
        var cell: UITableViewCell = SizingCellProvider.sizingCells[identifier]!
        dataProvider(cell: cell)
        return cell
    }
    
    
    private func initToken(identifier: String) {
        
        if SizingCellProvider.sizingTokens[identifier] == nil {
            SizingCellProvider.sizingTokens[identifier] = 0
        }
        
    }
}




// To add a specific calculator:, 
// 1. Add the implementation  which conforms to CellHeightCalculator
// 2. Put an identifier in the enumeration which represents the type.
// 3. Add it to the CellHeightCalculatorFactory


enum CellHeightCalculatorType {
    case Default, AutoLayout
}


class CellHeightCalculatorFactory {
    
    static func getCalculator(#type: CellHeightCalculatorType) -> CellHeightCalculator {
        
        switch type {
            
        case .AutoLayout:
            return AutoLayoutCellHeightCalculator()
        case .Default:
            return DefaultCellHeightCalculator()
            
        }
    }
    
}

protocol CellHeightCalculator {
    func calculateHeight(cell: UITableViewCell) -> CGFloat
}


class AutoLayoutCellHeightCalculator: CellHeightCalculator {
    
    func calculateHeight(cell: UITableViewCell) -> CGFloat {
        
        var size: CGSize = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
        return size.height
    }
    
}


class DefaultCellHeightCalculator: CellHeightCalculator {
    
    func calculateHeight(cell: UITableViewCell) -> CGFloat {
        
        let tableViewCellInset: CGFloat = 5
        
        let labelWidth: CGFloat = UIScreen.mainScreen().bounds.size.width - tableViewCellInset * 2
        
        var str1 = cell.textLabel?.text ?? ""
        var str2 = cell.detailTextLabel?.text ?? ""
        
        let titleText = NSAttributedString(string: str1, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16)] )
        let detailText = NSAttributedString(string: str2, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(11)] )
        
        let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading
        
        let boundingRectForTitleText: CGRect = titleText.boundingRectWithSize(
            CGSizeMake(labelWidth, CGFloat.max),
            options: options,
            context: nil)
        
        let boundingRectForDetail: CGRect = detailText.boundingRectWithSize(
            CGSizeMake(labelWidth, CGFloat.max),
            options: options,
            context: nil)
        
        return ceil(boundingRectForTitleText.size.height + boundingRectForDetail.size.height) + tableViewCellInset * 2
    }
}



