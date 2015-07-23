//
//  ICProtocols.swift
//  iCasting
//
//  Created by Tim van Steenoven on 23/04/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

protocol ModelProtocol {
    func initializeModel(json: JSON)
}


protocol MatchCardDelegate {
    func didRejectMatch()
    func didAcceptMatch()
}