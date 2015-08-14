//
//  MatchFields.swift
//  iCasting
//
//  Created by Tim van Steenoven on 15/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// This is currently a mess

protocol FieldPathProtocol {
    func getPath() -> [SubscriptType]
}

enum FieldRoots: Int, FieldPathProtocol {
    case RootJobContract, RootJobProfile, RootClient
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .RootJobContract:
            return ["job", "formSource", "contract"]
        case .RootJobProfile:
            return ["job", "formSource", "profile"]
        case .RootClient:
            return ["client"]
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
    case Read
    case ClientRating
    case ClientName, ClientCompany, ClientAvatar
    case JobTitle, JobDescShort, JobDescLong
    case JobDateTime, JobDateTimeType, JobDateStart, JobDateEnd, JobTimeStart, JobTimeEnd
    case JobContractLocation
    case JobProfile
    case JobPayment, JobContractPaymentMethod, JobContractBudget, JobContractTravelExpenses
    case JobProfileTalent
    
    func getPath() -> [SubscriptType] {
        switch self {
        case .Status:
            return ["status"]
        case .Read:
            return ["read", "talent"]
        case .ClientRating:
            return ["client", "company", "ratings"]
        case .ClientName:
            return ["client","name","display"]
        case .ClientCompany:
            return ["client","company","name"]
        case .ClientAvatar:
            return ["client","avatar","thumb"]
        case .JobTitle:
            return ["job","title"]
        case .JobDescShort:
            return ["job","desc"]
        case .JobDescLong:
            return ["job", "formSource", "descLong"]
        case .JobDateTime:
            return ["job", "formSource", "contract", "dateTime"]
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
        case .JobProfileTalent:
            return ["job", "formSource", "profile", "type"]
        case .JobProfile:
            return FieldRoots.RootJobProfile.getPath()
        default:
            return []
        }
    }
    
    var header: String {
        var comment = "Header text"
        switch self {
        case .JobProfile:
            return NSLocalizedString("specificJobInformation", comment: comment)
        case .JobDateTime:
            return NSLocalizedString("dateTime", comment: comment)
        case .JobContractLocation:
            return NSLocalizedString("location", comment: comment)
        case .JobContractTravelExpenses:
            return NSLocalizedString("travelExpenses", comment: comment)
        case .JobPayment:
            return NSLocalizedString("payment", comment: comment)
        default:
            return "To developer: No header"
        }
    }
}
