//
//  ICFunctions.swift
//  iCasting
//
//  Created by Tim van Steenoven on 18/05/15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import Foundation

func filterArrayForNil<U>(arr: [U?]) -> [U] {
    var notNilArray: [U] = [U]()
    for checkForNil in arr {
        if let notNil = checkForNil {
            notNilArray.append(notNil)
        }
    }
    return notNilArray
}

func filterDictionaryForNil<Key,U>(dict: [Key:U?]) -> [Key:U] {
    var notNilDict: [Key:U] = [Key:U]()
    for (k, v) in dict {
        if let notNil = v {
            notNilDict[k] = v
        }
    }
    return notNilDict
}


func filterDictionaryInArrayForNil<Key,U>(arr: [[Key:U?]]) -> [[Key:U]] {
    var notNilArray: [[Key:U]] = [[Key:U]]()
    for checkForNil in arr {
        for (k, v) in checkForNil {
            if let notNil = v {
                notNilArray.append([k:notNil])
            }
        }
    }
    return notNilArray
}


//[Fields: [ [String:String?] ] ]