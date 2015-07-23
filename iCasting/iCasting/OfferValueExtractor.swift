//
//  OfferValueExtractor.swift
//  iCasting
//
//  Created by Tim van Steenoven on 12/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// Modify a specific value from the API with a string connected to a key/value pair

enum OfferValueExtractor: String {
    
    case TypeDateTime = "type.dateTime"
    case DateStart = "dateStart"
    case DateEnd = "dateEnd"
    case TimeStart = "timeStart"
    case TimeEnd = "timeEnd"
    case HasBuyOff = "hasBuyOff"
    case CompleteBuyOff = "completeBuyOff"
    case HasTravelExpenses = "hasTravelExpenses"
    case Budget = "times1000"
    case BuyOffPeriod = "period"
    case BuyOffMedium = "medium"
    
    func modify(value: Any?) -> String? {
        
        if let v = value {
            
            switch self {
            case
            .TypeDateTime:
                
                let str = (v as! JSON).stringValue
                return getLocalizationForValue(str)
                
            case
            .DateStart,
            .DateEnd:
                
                let str = (v as! JSON).stringValue
                let components: [String] = str.componentsSeparatedByString("T")
                return components.first?.ICdateToString(ICDateFormat.General) ?? (str.isEmpty ? nil : str)
                
            case
            .TimeStart,
            .TimeEnd:
                
                return (v as! JSON).stringValue
                
            case
            .HasBuyOff,
            .CompleteBuyOff,
            .HasTravelExpenses:
                
                let boolString = "\((v as! JSON).boolValue)"
                let result = getLocalizationForValue(boolString)
                return result
                
            case
            .Budget:
                
                var intVal = (v as! JSON).intValue
                intVal = intVal / 1000
                let result = "€ \(intVal)"
                return result
                
            case
            .BuyOffPeriod:
                
                let double = (v as! JSON).doubleValue
                let numOfMonths = Int(double * 12)
                
                var number: Int
                var postfix: String
                
                if numOfMonths > 11 { //years
                    number = Int(double)
                    postfix = number == 1 ? getLocalizationForValue("year") : getLocalizationForValue("years")
                    
                } else {
                    number = numOfMonths
                    postfix = number == 1 ? getLocalizationForValue("month") : getLocalizationForValue("months")
                }
                
                let period: String = "\(number) " + postfix
                let forever: String = getLocalizationForValue("forever")
                let result = numOfMonths == 0 ? forever : period
                return result
                
            case
            .BuyOffMedium:
                
                var result: String = String(", ").join((v as! JSON).arrayValue.map { $0.stringValue } )
                return result.isEmpty ? nil : result
            }
        }
        
        return nil
    }
    
    private func getLocalizationForValue(value: String) -> String {
        
        let prefix = "negotiations.offer.value.%@"
        let formatted = String(format: prefix, value)
        return NSLocalizedString(formatted, comment: "")
    }
}
