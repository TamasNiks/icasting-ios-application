//
//  SizingCellProvider.swift
//  VariableCellHeightTestProject
//
//  Created by Tim van Steenoven on 02/06/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class SizingCellProvider {
    
    typealias CellDataProviderType = (cellConfigurator: AbstractCellConfigurator?)->()
    
    private var tableView: UITableView
    static var sizingTokens: [String : dispatch_once_t] = [String : dispatch_once_t]()
    static var sizingCells: [String : UITableViewCell] = [String : UITableViewCell]()
    
    var cellConfiguratorFactory: AbstractCellConfiguratorFactory
    
    init(tableView: UITableView, cellConfiguratorFactory: AbstractCellConfiguratorFactory) {
        
        self.tableView = tableView
        self.cellConfiguratorFactory = cellConfiguratorFactory
    }
    
    
    func heightForCustomCell(
        fromIdentifier identifier: CellIdentifierProtocol,
        configuratorType: ConfiguratorTypeProtocol?,
        calculatorType: CellHeightStrategyType,
        dataProvider: CellDataProviderType) -> CGFloat {
        
        // Intialize tokens for the dispatch_once function and grap the cell for one time only in the lifetime of the app
        
        initToken(identifier.rawValue)
        
        dispatch_once(&SizingCellProvider.sizingTokens[identifier.rawValue]!) {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(identifier.rawValue) as? UITableViewCell
            SizingCellProvider.sizingCells[identifier.rawValue] = cell
        }
        
        // First fill the cell with necessary sizing data like strings.
        
        let cell = provideCellWithDataForSizing(identifier, configuratorType: configuratorType, dataProvider: dataProvider)
        
        // Then grab a calculator based on the specified cell height calculator type. Typically this will be a standard cell or a custom cell with constraints. Either way, the cell needs to be prepared before using a calculator. To use the AutoLayout calculator, add constraints to the contentView of the cell.
       
        var calc: CellHeightStrategy = CellHeightStrategyFactory.getCalculator(type: calculatorType)
        
        let height = calc.calculateHeight(cell)

        return height
    }
    

    private func initToken(identifier: String) {
        
        if SizingCellProvider.sizingTokens[identifier] == nil {
            SizingCellProvider.sizingTokens[identifier] = 0
        }
        
    }
    

    private func provideCellWithDataForSizing(identifier: CellIdentifierProtocol, configuratorType: ConfiguratorTypeProtocol?, dataProvider: CellDataProviderType) -> UITableViewCell {
        
        let cell: UITableViewCell? = SizingCellProvider.sizingCells[identifier.rawValue]
        
        let configuratorFactory = MessageCellConfiguratorFactory(configuratorType: configuratorType, cell: cell)
        let configurator: AbstractCellConfigurator? = configuratorFactory.getConfigurator()
        
        dataProvider(cellConfigurator: configurator)
        
        return cell!
    }
    
}




// To add a specific calculator:, 
// 1. Add the implementation  which conforms to CellHeightCalculator
// 2. Put an identifier in the enumeration which represents the type.
// 3. Add it to the CellHeightStrategyFactory, you will get an compiler error message as a reminder


enum CellHeightStrategyType {
    
    case Default, AutoLayout
}


class CellHeightStrategyFactory {
    
    static func getCalculator(#type: CellHeightStrategyType) -> CellHeightStrategy {
        switch type {
        case .AutoLayout:
            return AutoLayoutCellHeightStrategy()
        case .Default:
            return DefaultCellHeightStrategy()
        }
    }
}


protocol CellHeightStrategy {
    func calculateHeight(cell: UITableViewCell) -> CGFloat
}


class AutoLayoutCellHeightStrategy: CellHeightStrategy {
    
    func calculateHeight(cell: UITableViewCell) -> CGFloat {
        
        let size: CGSize = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
        return size.height
    }
}


class DefaultCellHeightStrategy: CellHeightStrategy {
    
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

//class OneTextLabelHeightStrategy: CellHeightStrategy {
//    
//    func calculateHeight(cell: UITableViewCell) -> CGFloat {
//        
//        var item = model[indexPath.section]![indexPath.row]
//        let TableViewCellInset: CGFloat = 15
//        let labelWidth: CGFloat = self.tableView.bounds.size.width - TableViewCellInset * 2
//        
//        let text = NSAttributedString(string: item.values.first!, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(16)])
//        let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading | NSStringDrawingOptions.TruncatesLastVisibleLine
//        
//        func rect(str: NSAttributedString) -> CGRect {
//            return str.boundingRectWithSize(
//                CGSizeMake(labelWidth, CGFloat.max),
//                options: options,
//                context: nil)
//        }
//        
//        let boundingRectForText: CGRect = rect(text)
//        return ceil(boundingRectForText.size.height) + TableViewCellInset * 2
//        
//    }
//    
//}



