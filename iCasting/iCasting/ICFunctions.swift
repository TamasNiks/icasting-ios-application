//
//  ICFunctions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 18/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

func filterNil<U>(arr: [U?]) -> [U] {
    var notNilArray: [U] = [U]()
    for checkForNil in arr {
        if let notNil = checkForNil {
            notNilArray.append(notNil)
        }
    }
    return notNilArray
}