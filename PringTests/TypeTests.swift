//
//  TypeTests.swift
//  PringTests
//
//  Created by 1amageek on 2018/11/25.
//  Copyright © 2018 Stamp Inc. All rights reserved.
//

import XCTest
//@testable import Pring
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

@objcMembers
fileprivate class Doc: Object {
    dynamic var array: [String]                     = ["array"]
    dynamic var set: Set<String>                    = ["set"]
    dynamic var bool: Bool                          = true
    dynamic var binary: Data                        = "data".data(using: .utf8)!
    dynamic var url: URL                            = URL(string: "https://firebase.google.com/")!
    dynamic var int: Int                            = Int.max
    dynamic var float: Double                       = Double.infinity
    dynamic var date: Date                          = Date(timeIntervalSince1970: 100)
    dynamic var geoPoint: GeoPoint                  = GeoPoint(latitude: 0, longitude: 0)
    dynamic var dictionary: [String: Any]           = ["key": "value"]
    dynamic var string: String                      = "string"
    dynamic var file: File                          = File(data: TestDocument.image0().pngData()!, mimeType: .png)
    dynamic var files: [File]                       = []
    dynamic var refItem: Reference<ReferenceItem>   = Reference()
    dynamic var relationItem: Relation<ReferenceItem>   = Relation()
    dynamic var obj: Obj?
}

@objcMembers
fileprivate class Obj: Object {
    dynamic var array: [String]                     = ["array"]
}


class TypeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testTypeArrayAppend() {
        let document: Doc = Doc()
        document.array.append("array")
        let value: [String: [String]] = document.updateValue as! [String : [String]]
        XCTAssertEqual(value["array"], ["array", "array"])
    }

    func testTypeArrayRemove() {
        let document: Doc = Doc()
        document.array.remove(at: 0)
        let value: [String: [String]] = document.updateValue as! [String : [String]]
        XCTAssertEqual(value["array"], [])
    }

    func testTypeSetInsert() {
        let document: Doc = Doc()
        document.set.insert("set2")
        let value: [String: [String: Bool]] = document.updateValue as! [String : [String: Bool]]
        XCTAssertEqual(value["set"], ["set": true, "set2": true])
    }

    func testTypeSetRemove() {
        let document: Doc = Doc()
        document.set.remove("set")
        let value: [String: [String: Bool]] = document.updateValue as! [String : [String: Bool]]
        XCTAssertEqual(value["set"], [:])
    }

    func testTypeFilesAppend() {
        let document: Doc = Doc()
        let file: File = File(data: TestDocument.image0().pngData()!, mimeType: .png)
        document.files.append(file)
        let fileValues: [[String: Any]] = document.updateValue["files"] as! [[String: Any]]
        XCTAssertEqual(fileValues.first as! [String: String], file.value as! [String: String])
    }

    func testTypeFilesRemove() {
        let document: Doc = Doc()
        let file: File = File(data: TestDocument.image0().pngData()!, mimeType: .png)
        document.files.append(file)
        document.files.remove(at: 0)
        let fileValues: [[String: Any]] = document.updateValue["files"] as! [[String: Any]]
        XCTAssertEqual(fileValues.isEmpty, true)
    }
}
