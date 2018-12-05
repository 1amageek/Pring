//
//  PackTests.swift
//  PringTests
//
//  Created by 1amageek on 2018/12/05.
//  Copyright © 2018 Stamp Inc. All rights reserved.
//

import XCTest
import Firebase

@objcMembers
fileprivate class Doc: Object {
    dynamic var name: String?
    let nest: NestedCollection<Doc1> = []
}

@objcMembers
fileprivate class Doc0: Object {
    dynamic var name: String?
    let nest: NestedCollection<Doc1> = []
}

@objcMembers
fileprivate class Doc1: Object {
    dynamic var name: String?
    let nest: NestedCollection<Doc2> = []
}

@objcMembers
fileprivate class Doc2: Object {
    dynamic var name: String?
    let nest: NestedCollection<Doc3> = []
}

@objcMembers
fileprivate class Doc3: Object {
    dynamic var name: String?
}

class PackReferenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testReference() {
        let doc: Doc = Doc()
        let doc1: Doc1 = doc.nest.doc("doc1")
        XCTAssertEqual(doc1.reference.path, "version/1/doc/\(doc.id)/nest/doc1")
        let doc2: Doc2 = doc1.nest.doc("doc2")
        XCTAssertEqual(doc2.reference.path, "version/1/doc/\(doc.id)/nest/doc1/nest/doc2")
        let doc3: Doc3 = doc2.nest.doc("doc3")
        XCTAssertEqual(doc3.reference.path, "version/1/doc/\(doc.id)/nest/doc1/nest/doc2/nest/doc3")
    }

    func testDoc() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "")

        let doc: Doc = Doc()
        doc.name = "doc"

        let doc1: Doc1 = Doc1()
        doc1.name = "doc1"

        let doc2: Doc2 = Doc2()
        doc2.name = "doc2"

        let doc3: Doc3 = Doc3()
        doc3.name = "doc3"

        doc.nest.insert(doc1)
        doc1.nest.insert(doc2)
        doc2.nest.insert(doc3)

        doc.save { (_, error) in
            let doc: Doc = Doc(id: doc.id, value: [:])
            doc.nest.query.dataSource().onCompleted({ (_, docs) in
                XCTAssert(!docs.isEmpty)
                let doc1: Doc1 = docs.first!
                XCTAssertEqual(doc1.name!, "doc1")
                doc1.nest.query.dataSource().onCompleted({ (_, docs) in
                    XCTAssert(!docs.isEmpty)
                    let doc2: Doc2 = docs.first!
                    XCTAssertEqual(doc2.name!, "doc2")
                    doc2.nest.query.dataSource().onCompleted({ (_, docs) in
                        XCTAssert(!docs.isEmpty)
                        let doc3: Doc3 = docs.first!
                        XCTAssertEqual(doc3.name!, "doc3")
                        XCTAssert(!docs.isEmpty)

                        doc3.update({ (_) in

                            expectation.fulfill()
                        })
                    }).get()
                }).get()
            }).get()
        }
        self.wait(for: [expectation], timeout: 30)
    }
}

