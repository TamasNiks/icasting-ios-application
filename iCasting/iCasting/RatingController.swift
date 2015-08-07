//
//  RatingController.swift
//  AlertViewController
//
//  Created by Tim van Steenoven on 05/08/15.
//  Copyright (c) 2015 Tim van Steenoven. All rights reserved.
//

import UIKit

class RatingController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerView: UIPickerView!
    var alertController: UIAlertController!
    var valuesForComponents = [0,0]
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        
        self.viewController = viewController
    }
    
    typealias RatingCompletionHandler = (grade: String)->Void
    
    func show(ratingCompletionHandler: RatingCompletionHandler) {
        presentRating(wrongInput: false, ratingCompletionHandler: ratingCompletionHandler)
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 11
    }
    
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 90
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        let value = translateValue(row: row, component: component)
        return row == 0 ? "" : "\(value)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let value = translateValue(row: row, component: component)
        valuesForComponents[component] = value
        setValueForTextField()
    }
    
    private func translateValue(#row: Int, component: Int) -> Int {
        
        var row = row
        
        if component == 0 {
            if row == 0 {
                row = 0
            }
        }
        
        if component == 1 {
            row = row-1
            if row < 0 {
                row = 0
            }
        }
    
        return row
    }
    
    private func setValueForTextField() {
        
        let textField = alertController.textFields![0] as! UITextField
        let action = alertController.actions[0] as! UIAlertAction
        
        // Because it is not possible to rate higher than 10, set the decimal (component 1) to zero
        var vfc = valuesForComponents
        if vfc[0] == 10 {
            vfc[1] = 0
        }
        
        let stringValuesForComponents = vfc.map { "\($0)" }
        
        let rating = ".".join(stringValuesForComponents)
        
        if validateRating(rating) {
            textField.text = rating
            action.enabled = true
        } else {
            textField.text.removeAll(keepCapacity: false)
            action.enabled = false
        }
        
    }
    
    private func validateRating(rating: String) -> Bool {
        
        let num = (rating as NSString).floatValue
        return num < 1 || num > 10 ? false : true
    }
    
    private func presentRating(#wrongInput: Bool, invalidRating: String = String(), ratingCompletionHandler: RatingCompletionHandler) {
        
        var title = "Rate client"
        var message = "Please rate the client. The higher the points the better the rating."
        var alertActionStyle = UIAlertActionStyle.Default
        if wrongInput {
            title = "Wrong rating"
            message = "The rating is invalid. Please give a rating in the range of 1 and 10, for example: 8.5 or 7."
            alertActionStyle = UIAlertActionStyle.Destructive
        }
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler { [weak self] (textField) -> Void in
            
            var pv = UIPickerView()
            pv.dataSource = self
            pv.delegate = self
            
            textField.font = UIFont.boldSystemFontOfSize(24)
            textField.textAlignment = NSTextAlignment.Center
            textField.tintColor = UIColor.clearColor()
            textField.borderStyle = UITextBorderStyle.None
            textField.inputView = pv
            textField.placeholder = "0.0"

            // Hack
            if let container = textField.superview {
                if let effectView: AnyObject = container.superview?.subviews[0] {
                    
                    container.backgroundColor = UIColor.clearColor()
                    effectView.removeFromSuperview()
                }
            }
        }
        
        let applyAction = UIAlertAction(title: "Apply rating", style: alertActionStyle) { [weak self] (action) -> Void in
            
            let textField = self!.alertController.textFields![0] as! UITextField
            let rating = textField.text
            ratingCompletionHandler(grade: rating)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: UIAlertActionStyle.Cancel) { (action) -> Void in }
        
        applyAction.enabled = false
        
        alertController.addAction(applyAction)
        alertController.addAction(cancelAction)
        
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }

}