 //
//  TestDocument.swift
//  Salada2Tests
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore

@objcMembers
class TestDocument: Object {
    var array: [String]                     = ["array"]
    var set: Set<String>                    = ["set"]
    var bool: Bool                          = true
    var binary: Data                        = "data".data(using: .utf8)!
//    var file: File                      =
    var url: URL                            = URL(string: "https://firebase.google.com/")!
    var int: Int                            = Int.max
    var float: Double                       = Double.infinity
    var date: Date                          = Date(timeIntervalSince1970: 100)
    var geoPoint: GeoPoint                  = GeoPoint(latitude: 0, longitude: 0)
    var dictionary: [AnyHashable: Any]      = ["key": "value"]
    var relation: Relation<TestDocument>    = []
    var string: String                      = "string"
}
