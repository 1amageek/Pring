//
//  PringTests.swift
//  PringTests
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import XCTest
//@testable import Pring
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

class FirebaseTest {

    static let shared: FirebaseTest = FirebaseTest()

    init () {
        FirebaseApp.configure()
    }

}

class PringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObject() {
        XCTContext.runActivity(named: "Create") { (activity) in
            let expectation: XCTestExpectation = XCTestExpectation(description: "create document")
            let document: TestDocument = TestDocument()

            document.save { (ref, error) in

                TestDocument.get(ref!.documentID, block: { (document, error) in
                    XCTAssertNotNil(document)

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

                    XCTContext.runActivity(named: "Update") { (activity) in

                        document?.array = ["update"]
                        document?.set = ["update"]
                        document?.bool = false
                        document?.binary = "update".data(using: .utf8)!
                        document?.url = URL(string: "https://firebase.google.com/update")!
                        document?.int = 0
                        document?.float = 0
                        document?.date = Date(timeIntervalSince1970: 1000)
                        document?.geoPoint = GeoPoint(latitude: 1, longitude: 1)
                        document?.array = ["update"]
                        document?.dictionary = ["key": "update"]
                        document?.string = "update"

                        document?.update({ (error) in
                            TestDocument.get(document!.id, block: { (document, error) in
                                XCTAssertNotNil(document)
                                print(document)
                                XCTAssertEqual(document?.array.first, "update")
                                XCTAssertEqual(document?.set.first, "update")
                                XCTAssertEqual(document?.bool, false)
                                XCTAssertEqual(String(data: document!.binary, encoding: .utf8), "update")
                                XCTAssertEqual(document?.url.absoluteString, "https://firebase.google.com/update")
                                XCTAssertEqual(document?.int, 0)
                                XCTAssertEqual(document?.float, 0)
                                XCTAssertEqual(document?.date, Date(timeIntervalSince1970: 1000))
                                XCTAssertEqual(document?.geoPoint, GeoPoint(latitude: 0, longitude: 0))
                                XCTAssertEqual(document?.dictionary.keys.first, "key")
                                XCTAssertEqual(document?.dictionary.values.first as! String, "update")
                                XCTAssertEqual(document?.string, "update")
                                expectation.fulfill()
                            })
                        })

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {

                        })
                    }

//                    XCTContext.runActivity(named: "Delete") { (activity) in
//                        TestDocument.delete(id: document!.id) { error in
//                            TestDocument.get(document!.id, block: { (document, error) in
//                                XCTAssertNil(document)
//                                expectation.fulfill()
//                            })
//                        }
//                    }
                })
            }
            self.wait(for: [expectation], timeout: 10)
        }
    }

    func testDataType() {

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
