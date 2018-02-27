//
//  DocumentCRUDTests.swift
//  PringTests
//
//  Created by 1amageek on 2018/01/27.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import XCTest
@testable import Pring
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

class DocumentCRUDTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testCreateDocument() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test document properties")
        let document: TestDocument = TestDocument(id: "hoge")
        let item: ReferenceItem = ReferenceItem()
        document.relationItem.set(item)
        document.refItem.set(item)
        document.save { (ref, error) in

            TestDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)

                XCTAssertEqual(document?.type, .custom)
                XCTAssertEqual(document?.array.first, "array")
                XCTAssertEqual(document?.set.first, "set")
                XCTAssertEqual(document?.bool, true)
                XCTAssertEqual(String(data: document!.binary, encoding: .utf8), "data")
                XCTAssertEqual(document?.url.absoluteString, "https://firebase.google.com/")
                XCTAssertEqual(document?.int, Int.max)
                XCTAssertEqual(document?.float, Double.infinity)
                XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 100))
                XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 0, longitude: 0))
                XCTAssertEqual(document?.dictionary.keys.first, "key")
                XCTAssertEqual(document?.dictionary.values.first as! String, "value")
                XCTAssertEqual(document?.string, "string")
                XCTAssertEqual(document?.refItem.id, item.id)
                XCTAssertEqual(document?.relationItem.id, item.id)

                let item: ReferenceItem = ReferenceItem()

                document?.type = .update
                document?.array = ["update"]
                document?.set = ["update"]
                document?.bool = false
                document?.binary = "update".data(using: .utf8)!
                document?.url = URL(string: "https://firebase.google.com/update")!
                document?.int = 0
                document?.float = 0
                document?.date = Date(timeIntervalSince1970: 1000)
                document?.geoPoint = GeoPoint(latitude: 1, longitude: 1)
                document?.dictionary = ["key": "update"]
                document?.string = "update"
                document?.relationItem.set(item)
                document?.refItem.set(item)

                document?.update({ (error) in
                    TestDocument.get(document!.id, block: { (document, error) in
                        XCTAssertNotNil(document)
                        XCTAssertEqual(document?.type, .update)
                        XCTAssertEqual(document?.array.first, "update")
                        XCTAssertEqual(document?.set.first, "update")
                        XCTAssertEqual(document?.bool, false)
                        XCTAssertEqual(String(data: document!.binary, encoding: .utf8), "update")
                        XCTAssertEqual(document?.url.absoluteString, "https://firebase.google.com/update")
                        XCTAssertEqual(document?.int, 0)
                        XCTAssertEqual(document?.float, 0)
                        XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 1000))
                        XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 1, longitude: 1))
                        XCTAssertEqual(document?.dictionary.keys.first, "key")
                        XCTAssertEqual(document?.dictionary.values.first as! String, "update")
                        XCTAssertEqual(document?.string, "update")
                        XCTAssertEqual(document?.refItem.id, item.id)
                        XCTAssertEqual(document?.relationItem.id, item.id)
                        document?.delete { (error) in
                            TestDocument.get(document!.id, block: { (document, error) in
                                XCTAssertNil(document)
                                expectation.fulfill()
                            })
                        }
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testDocument() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test document properties")
        let document: TestDocument = TestDocument()

        document.save { (ref, error) in

            TestDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)

                XCTAssertEqual(document?.type, .custom)
                XCTAssertEqual(document?.array.first, "array")
                XCTAssertEqual(document?.set.first, "set")
                XCTAssertEqual(document?.bool, true)
                XCTAssertEqual(String(data: document!.binary, encoding: .utf8), "data")
                XCTAssertEqual(document?.url.absoluteString, "https://firebase.google.com/")
                XCTAssertEqual(document?.int, Int.max)
                XCTAssertEqual(document?.float, Double.infinity)
                XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 100))
                XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 0, longitude: 0))
                XCTAssertEqual(document?.dictionary.keys.first, "key")
                XCTAssertEqual(document?.dictionary.values.first as! String, "value")
                XCTAssertEqual(document?.string, "string")


                document?.type = .update
                document?.array = ["update"]
                document?.set = ["update"]
                document?.bool = false
                document?.binary = "update".data(using: .utf8)!
                document?.url = URL(string: "https://firebase.google.com/update")!
                document?.int = 0
                document?.float = 0
                document?.date = Date(timeIntervalSince1970: 1000)
                document?.geoPoint = GeoPoint(latitude: 1, longitude: 1)
                document?.dictionary = ["key": "update"]
                document?.string = "update"

                document?.update({ (error) in
                    TestDocument.get(document!.id, block: { (document, error) in
                        XCTAssertNotNil(document)
                        XCTAssertEqual(document?.type, .update)
                        XCTAssertEqual(document?.array.first, "update")
                        XCTAssertEqual(document?.set.first, "update")
                        XCTAssertEqual(document?.bool, false)
                        XCTAssertEqual(String(data: document!.binary, encoding: .utf8), "update")
                        XCTAssertEqual(document?.url.absoluteString, "https://firebase.google.com/update")
                        XCTAssertEqual(document?.int, 0)
                        XCTAssertEqual(document?.float, 0)
                        XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 1000))
                        XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 1, longitude: 1))
                        XCTAssertEqual(document?.dictionary.keys.first, "key")
                        XCTAssertEqual(document?.dictionary.values.first as! String, "update")
                        XCTAssertEqual(document?.string, "update")
                        document?.delete { (error) in
                            TestDocument.get(document!.id, block: { (document, error) in
                                XCTAssertNil(document)
                                expectation.fulfill()
                            })
                        }
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testOptionalDocument() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test optional document properties")
        let document: TestOptionalDocument = TestOptionalDocument()

        document.array = ["array"]
        document.set = ["set"]
        document.bool = true
        document.binary = "data".data(using: .utf8)!
        document.url = URL(string: "https://firebase.google.com")!
        document.int = Int.max
        document.float = Double.infinity
        document.date = Date(timeIntervalSince1970: 100)
        document.geoPoint = GeoPoint(latitude: 0, longitude: 0)
        document.dictionary = ["key": "value"]
        document.string = "string"

        document.save { (ref, error) in
            TestOptionalDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)
                XCTAssertEqual(document?.array?.first, "array")
                XCTAssertEqual(document?.set?.first, "set")
                XCTAssertEqual(document?.bool, true)
                XCTAssertEqual(String(data: document!.binary!, encoding: .utf8), "data")
                XCTAssertEqual(document?.url?.absoluteString, "https://firebase.google.com")
                XCTAssertEqual(document?.int, Int.max)
                XCTAssertEqual(document?.float, Double.infinity)
                XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 100))
                XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 0, longitude: 0))
                XCTAssertEqual(document?.dictionary?.keys.first, "key")
                XCTAssertEqual(document?.dictionary?.values.first as! String, "value")
                XCTAssertEqual(document?.string, "string")

                document?.array = ["update"]
                document?.set = ["update"]
                document?.bool = false
                document?.binary = "update".data(using: .utf8)!
                document?.url = URL(string: "https://firebase.google.com/update")!
                document?.int = 0
                document?.float = 0
                document?.date = Date(timeIntervalSince1970: 1000)
                document?.geoPoint = GeoPoint(latitude: 1, longitude: 1)
                document?.dictionary = ["key": "update"]
                document?.string = "update"

                document?.update({ (error) in
                    TestOptionalDocument.get(document!.id, block: { (document, error) in
                        XCTAssertNotNil(document)
                        XCTAssertEqual(document?.array?.first, "update")
                        XCTAssertEqual(document?.set?.first, "update")
                        XCTAssertEqual(document?.bool, false)
                        XCTAssertEqual(String(data: document!.binary!, encoding: .utf8), "update")
                        XCTAssertEqual(document?.url?.absoluteString, "https://firebase.google.com/update")
                        XCTAssertEqual(document?.int, 0)
                        XCTAssertEqual(document?.float, 0)
                        XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 1000))
                        XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 1, longitude: 1))
                        XCTAssertEqual(document?.dictionary?.keys.first, "key")
                        XCTAssertEqual(document?.dictionary?.values.first as! String, "update")
                        XCTAssertEqual(document?.string, "update")
                        document?.delete { (error) in
                            TestOptionalDocument.get(document!.id, block: { (document, error) in
                                XCTAssertNil(document)
                                expectation.fulfill()
                            })
                        }
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
}
