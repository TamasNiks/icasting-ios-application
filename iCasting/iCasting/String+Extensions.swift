//
//  String+Extensions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 13/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

extension String {
    
    enum ICDateFormat: String {
        case
        Match = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'+'ss':'ss",
        News = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'000'Z'", //2015-01-31T23:00:00.000Z
        General = "yyyy'-'MM'-'dd"
    }
    
    
    
    func ICdateToString(format: ICDateFormat) -> String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format.rawValue
        
        //        if format == ICDateFormat.General {
        //
        //        }
        
        
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
    
    var ICLocalizedOfferName: String {
        
        let formatted = String(format: "negotiations.offer.name.%@", self)
        let localizedName = NSLocalizedString(formatted, comment: "The name of an offer negotiation point.")
        return localizedName
    }
    
    var ICLocalizedNegotiationSubject: String {
        let formatted = String(format: "negotiations.subject.title.%@", self)
        let localizedName = NSLocalizedString(formatted, comment: "The title for every main category in the job overview.")
        return localizedName
    }
    
}
