//
//  MatchFields.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation


protocol FieldPathProtocol {
    func getPath() -> [SubscriptType]
}

enum FieldRoots: Int, FieldPathProtocol {
    case RootJobContract, RootJobProfile
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .RootJobContract:
            return ["job", "formSource", "contract"]
        case .RootJobProfile:
            return ["job", "formSource", "profile"]
        }
    }
}


enum FieldID: Int, FieldPathProtocol {
    case MatchCardID, JobID
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .MatchCardID:
            return ["_id"]
        case .JobID:
            return ["job","_id"]
        }
    }
}

enum Fields: Int, FieldPathProtocol {
    
    case Status
    case ClientName, ClientCompany, ClientAvatar
    case JobTitle, JobDescription
    case JobContractDateTime, JobDateStart, JobDateEnd, JobTimeStart, JobTimeEnd
    case JobContractLocation
    case JobProfile
    case JobPayment, JobContractPaymentMethod, JobContractBudget, JobContractTravelExpenses
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .Status:
            return ["status"]
        case .ClientName:
            return ["client","name","display"]
        case .ClientCompany:
            return ["client","company","name"]
        case .ClientAvatar:
            return ["client","avatar","thumb"]
        case .JobTitle:
            return ["job","title"]
        case .JobDescription:
            return ["job","desc"]
        case .JobDateStart:
            return ["job", "formSource", "contract", "dateTime", "dateStart"]
        case .JobDateEnd:
            return ["job", "formSource", "contract", "dateTime", "dateEnd"]
        case .JobTimeStart:
            return ["job", "formSource", "contract", "dateTime", "timeStart"]
        case .JobTimeEnd:
            return ["job", "formSource", "contract", "dateTime", "timeEnd"]
        case .JobContractLocation:
            return ["job", "formSource", "contract", "location"]
        case .JobContractPaymentMethod:
            return ["job", "formSource", "contract", "paymentMethod", "type"]
        case .JobContractBudget:
            return ["job", "formSource", "contract", "budget", "times1000"]
        case .JobContractTravelExpenses:
            return ["job", "formSource", "contract", "travelExpenses", "hasTravelExpenses"]
        case .JobProfile:
            return FieldRoots.RootJobProfile.getPath()
        default:
            return []
        }
    }
    
    var header: String {
        switch self {
        case .JobContractDateTime:
            return NSLocalizedString("dateTime", comment: "Header text for all the time properties")
        case .JobContractLocation:
            return NSLocalizedString("location", comment: "Header text for all the location properties")
        case .JobContractTravelExpenses:
            return NSLocalizedString("travelExpenses", comment: "Header text for all the travelexpenses properties")
        case .JobPayment:
            return NSLocalizedString("payment", comment: "Header text for all the travelexpenses properties")
        default:
            return "To developer: No header"
        }
    }
}
