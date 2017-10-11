 //
//  TestDocument.swift
//  Pring2Tests
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit
import Pring

@objcMembers
class TestDocument: Object {
    dynamic var array: [String]                     = ["array"]
    dynamic var set: Set<String>                    = ["set"]
    dynamic var bool: Bool                          = true
    dynamic var binary: Data                        = "data".data(using: .utf8)!
//    var file: File                          = File(data: UIImagePNGRepresentation(UIImage(named: "Pring.png")!)!)
    dynamic var url: URL                            = URL(string: "https://firebase.google.com/")!
    dynamic var int: Int                            = Int.max
    dynamic var float: Double                       = Double.infinity
    dynamic var date: Date                          = Date(timeIntervalSince1970: 100)
    dynamic var geoPoint: GeoPoint                  = GeoPoint(latitude: 0, longitude: 0)
    dynamic var dictionary: [AnyHashable: Any]      = ["key": "value"]
    dynamic var relation: Relation<TestDocument>    = []
    dynamic var string: String                      = "string"
}
