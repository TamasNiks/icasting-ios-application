//
//  UITableView+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

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
    
    
    func calculateHeight(fromTitle title: String, titleFontSize: CGFloat, andDetail detail: String, detailFontSize: CGFloat) -> CGFloat {
        
        let tableViewCellInset: CGFloat = 15
        
        let labelWidth: CGFloat = UIScreen.mainScreen().bounds.size.width - tableViewCellInset * 2
        
        let titleText = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(titleFontSize)] )
        let detailText = NSAttributedString(string: detail, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(detailFontSize)] )

        let options: NSStringDrawingOptions = NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading | NSStringDrawingOptions.TruncatesLastVisibleLine

        func rect(str: NSAttributedString) -> CGRect {
            return str.boundingRectWithSize(
                CGSizeMake(labelWidth, CGFloat.max),
                options: options,
                context: nil)
        }

        let boundingRectForTitleText: CGRect = rect(titleText)
        let boundingRectForDetail: CGRect = rect(detailText)

        return ceil(boundingRectForTitleText.size.height + boundingRectForDetail.size.height) + tableViewCellInset * 2
    }
    
    func calculateHeight(fromString string: String, forFontSize size: CGFloat) -> CGFloat {
        
        let tableViewCellInset: CGFloat = 15
        
        //let labelWidth: CGFloat = self.bounds.size.width - TableViewCellInset * 2
        let labelWidth: CGFloat = UIScreen.mainScreen().bounds.size.width - tableViewCellInset * 2
        
        let text = NSAttributedString(string: string, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(size)])
        
        
        func rect(str: NSAttributedString) -> CGRect {
            
            let options: NSStringDrawingOptions =   NSStringDrawingOptions.UsesLineFragmentOrigin |
                NSStringDrawingOptions.UsesFontLeading |
                NSStringDrawingOptions.TruncatesLastVisibleLine
            
            return str.boundingRectWithSize(
                CGSizeMake(labelWidth, CGFloat.max),
                options: options,
                context: nil)
        }
        
        let boundingRectForText: CGRect = rect(text)
        return ceil(boundingRectForText.size.height) + tableViewCellInset * 2
    }
    
    
}
