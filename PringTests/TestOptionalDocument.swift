//
//  TestOptionalDocument.swift
//  PringTests
//
//  Created by 1amageek on 2017/10/26.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit
import Pring

@objcMembers
class TestOptionalDocument: Object {

    dynamic var array: [String]?
    dynamic var set: Set<String>?
    dynamic var bool: Bool = false
    dynamic var binary: Data?
    dynamic var url: URL?
    dynamic var int: Int = 0
    dynamic var float: Double = 0
    dynamic var date: Date?
    dynamic var geoPoint: GeoPoint?
    dynamic var dictionary: [String: Any]?
    dynamic var string: String?
    dynamic var file: File?

    let referenceCollection: ReferenceCollection<TestDocument>  = []
    let nextedCollection: NestedCollection<NestedItem>          = []

    static func image0() -> UIImage {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.green.cgColor)
        context.fill(frame)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func image1() -> UIImage {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50)
        UIGraphicsBeginImageContext(frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.green.cgColor)
        context.fill(frame)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
