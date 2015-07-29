//
//  SegueIdentifier.swift
//  iCasting
//
//  Created by Tim van Steenoven on 24/07/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

// When creating or changing a segue, modify the struct, and use this instead of magic strings
struct SegueIdentifier {
    
    static let Settings = "settingsSegueID"
    static let Conversation = "showConversation"
    static let Main = "showMain"
    static let CastingObjects = "showCastingObjects"
    static let MatchID = "showMatchID"
    static let NewsDetail = "ShowDetail2News"
    
    struct Unwind {
        static let Login = "unwindToLogin"
        static let Family = "unwindToFamilySegueID"
        static let CastingObjects = "unwindToChooseCastingObject"
    }
}