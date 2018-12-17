//
//  ListTests.swift
//  PringTests
//
//  Created by 1amageek on 2018/12/17.
//  Copyright © 2018 Stamp Inc. All rights reserved.
//

import XCTest
import Firebase


@objcMembers
fileprivate class Doc0: Object {
    dynamic var name: String?
    let list: List<Doc1> = []
}

@objcMembers
fileprivate class Doc1: Object {
    dynamic var name: String?
    dynamic var age: Int = 0
}


class ListTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testList() {
        let doc0: Doc0 = Doc0()
        let doc1: Doc1 = Doc1()
        doc1.name = "doc1"
        doc0.list.append(doc1)
        XCTAssertEqual(doc0.list.first!.id, doc1.id)
        XCTAssertEqual(doc0.list.first!.name, "doc1")
    }

    func testListSaveUpdateDelete() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "")
        let doc0: Doc0 = Doc0()
        let doc1: Doc1 = Doc1()
        let doc2: Doc1 = Doc1()
        doc1.name = "doc1"
        doc1.age = 3
        doc2.name = "doc2"
        doc2.age = 32
        doc0.list.append(doc2)
        doc0.list.append(doc1)
        doc0.save { (_, _) in
            Doc0.get(doc0.id, block: { (doc, _) in
                XCTAssertTrue(doc!.list.contains(doc1))
                doc!.list[doc1.id].name = "update"
                doc?.update({ (_) in
                    Doc0.get(doc0.id, block: { (doc, _) in
                        XCTAssertTrue(doc!.list.contains(doc1))
                        XCTAssertEqual(doc!.list[doc1.id].name, "update")
                        XCTAssertEqual(doc!.list[doc1.id].age, 3)
                        doc?.list.remove(doc!.list.first!)
                        doc?.update({ (_) in
                            Doc0.get(doc0.id, block: { (doc, _) in
                                doc?.list.forEach({ (doc) in
                                    print(doc)
                                })
                                XCTAssertEqual(doc!.list.count, 1)
                                expectation.fulfill()
                            })
                        })
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 30)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
