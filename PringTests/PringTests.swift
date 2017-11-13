//
//  PringTests.swift
//  PringTests
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import XCTest
@testable import Pring
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

    func testSample() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test optional document properties")
        let document: TestOptionalDocument = TestOptionalDocument()
//        document.int = Int.max
//        document.float = Double.infinity
        document.string = "update"
        document.save { (ref, error) in
            
            TestOptionalDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)
                XCTAssertEqual(document?.string, "update")
//                XCTAssertEqual(document?.int, Int.max)
//                XCTAssertEqual(document?.float, Double.infinity)
                expectation.fulfill()
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
                document?.delete { (error) in
                    TestOptionalDocument.get(document!.id, block: { (document, error) in
                        XCTAssertNil(document)
                        expectation.fulfill()
                    })
                }
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFiles() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Files")
        let document: MultipleFilesDocument = MultipleFilesDocument()

        document.file0 = File(data: UIImagePNGRepresentation(MultipleFilesDocument.image())!, mimeType: .png)
        document.file1 = File(data: UIImagePNGRepresentation(MultipleFilesDocument.image())!, mimeType: .png)
        document.file2 = File(data: UIImagePNGRepresentation(MultipleFilesDocument.image())!, mimeType: .png)

        let tasks = document.save { (ref, error) in
            MultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)
                guard let document: MultipleFilesDocument = document else {
                    return
                }

                let ref0 = document.file0?.ref
                let ref1 = document.file1?.ref
                let ref2 = document.file2?.ref

                ref0?.getData(maxSize: 1000000, completion: { (data, error) in
                    XCTAssertNotNil(data)
                    ref1?.getData(maxSize: 1000000, completion: { (data, error) in
                        XCTAssertNotNil(data)
                        ref2?.getData(maxSize: 1000000, completion: { (data, error) in
                            XCTAssertNotNil(data)
                            document.file0?.delete({ (error) in
                                document.file1?.delete({ (error) in
                                    document.file2?.delete({ (error) in
                                        MultipleFilesDocument.get(ref!.documentID, block: { (doc, error) in
                                            guard let doc: MultipleFilesDocument = doc else {
                                                return
                                            }
                                            XCTAssertNotNil(doc)
                                            XCTAssertNil(doc.file0)
                                            XCTAssertNil(doc.file1)
                                            XCTAssertNil(doc.file2)

                                            ref0?.getData(maxSize: 1000000, completion: { (data, error) in
                                                XCTAssertNil(data)
                                                ref1?.getData(maxSize: 1000000, completion: { (data, error) in
                                                    XCTAssertNil(data)
                                                    ref2?.getData(maxSize: 1000000, completion: { (data, error) in
                                                        XCTAssertNil(data)
                                                        expectation.fulfill()
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
        print(tasks)
        XCTAssertEqual(tasks.count, 3)
        self.wait(for: [expectation], timeout: 30)
    }

    func testNestedFiles() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Nested File delete")

        let document: MultipleFilesDocument = MultipleFilesDocument()
        let item: MultipleFilesNestedItem = MultipleFilesNestedItem()
        item.file = File(data: UIImagePNGRepresentation(MultipleFilesNestedItem.image())!, mimeType: .png)
        document.files.insert(item)
        let id: String = item.id

        document.save { (ref, error) in
            MultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: MultipleFilesDocument = document else {
                    return
                }
                XCTAssertNotNil(document)
                document.files.get(id, block: { (item, error) in
                    let ref = item?.file?.ref
                    ref?.getData(maxSize: 1000000, completion: { (data, error) in
                        XCTAssertNotNil(data)
                        item?.file?.delete({ (error) in
                            ref?.getData(maxSize: 1000000, completion: { (data, error) in
                                XCTAssertNil(data)
                                expectation.fulfill()
                            })
                        })
                    })
                })
            })
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testMemory() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test File")
        weak var weakDocument: TestDocument?

        do {
            let document: TestDocument = TestDocument()
            weakDocument = document
            document.save({ (ref, error) in
                TestDocument.get(ref!.documentID, block: { (document, error) in
                    let file1: File = File(data: UIImagePNGRepresentation(TestDocument.image1())!, mimeType: .png)
                    document?.file = file1
                    document?.file.update({ (metadata, error) in
                        TestDocument.get(ref!.documentID, block: { (document, error) in
                            expectation.fulfill()
                        })
                    })
                })
            })
        }

        self.wait(for: [expectation], timeout: 10)
        XCTAssertNil(weakDocument)
    }

    func testNestedCollection() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test NestedCollection")
        let document: TestDocument = TestDocument()
        let nestedItem: NestedItem = NestedItem()
        document.nextedCollection.insert(nestedItem)
        document.save { (ref, error) in
            XCTAssertEqual(document.nextedCollection.first?.string, "nested")
            TestDocument.get(ref!.documentID, block: { (document, error) in
                document?.nextedCollection.get(nestedItem.id, block: { (item, error) in
                    XCTAssertEqual(item?.array.first, "nested")
                    XCTAssertEqual(item?.set.first, "nested")
                    XCTAssertEqual(item?.bool, true)
                    XCTAssertEqual(String(data: item!.binary, encoding: .utf8), "nested")
                    XCTAssertEqual(item?.url.absoluteString, "https://firebase.google.com/nested")
                    XCTAssertEqual(item?.int, Int.max)
                    XCTAssertEqual(item?.float, Double.infinity)
                    XCTAssertEqual(item?.date, Date(timeIntervalSince1970: 100))
                    XCTAssertEqual(item?.geoPoint, GeoPoint(latitude: 0, longitude: 0))
                    XCTAssertEqual(item?.dictionary.keys.first, "key")
                    XCTAssertEqual(item?.dictionary.values.first as! String, "nested")
                    XCTAssertEqual(item?.string, "nested")
                    expectation.fulfill()
                })
            })

        }
        self.wait(for: [expectation], timeout: 10)
    }

    var dataSource: DataSource<DataSourceItem>?

    func testDataSource() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test DataSource")

        let group: DispatchGroup = DispatchGroup()
        let queue: DispatchQueue = DispatchQueue(label: "Dispatch.Queue")
        let count: Int = 10
        queue.async {
            (0..<count).forEach({ (index) in
                group.enter()
                let document: DataSourceItem = DataSourceItem()
                document.index = index
                document.save({ (ref, error) in
                    group.leave()
                })
            })
            group.notify(queue: .main, execute: {
                self.dataSource = DataSourceItem.query.dataSource().on({ (snapshot, change) in
                    switch change {
                    case .update(deletions: _, insertions: let insertions, modifications: _):
                        XCTAssertEqual(insertions.count, 1)
                    default: break
                    }
                }).onCompleted({ (snapshot, items) in
                    XCTAssertEqual(snapshot?.count, count)
                    items.forEach({ (item) in
                        item.delete()
                    })
                    expectation.fulfill()
                }).get()
            })
            group.wait()
        }
        self.wait(for: [expectation], timeout: 20)
    }

    func testNestedCollectionsCount() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test NestedCollection")

        let object: CollectionObject = CollectionObject()
        object.save { (ref, error) in
            if let error = error {
                print(error)
            }
            CollectionObject.get(ref!.documentID, block: { (object, _) in
                guard let object: CollectionObject = object else {
                    return
                }
                let group: DispatchGroup = DispatchGroup()
                let queue: DispatchQueue = DispatchQueue(label: "Dispatch.Queue")
                let count: Int = 5
                queue.async {
                    (0..<count).forEach({ (index) in
                        group.enter()
                        let item: NestedItem = NestedItem()
                        object.nestedCollection.insert(item, block: { (error) in
                            print("1!!!xxx1")
                            group.leave()
                        })
                    })
                }
                group.notify(queue: .main, execute: {

                    CollectionObject.get(ref!.documentID, block: { (object, _) in
                        guard let object: CollectionObject = object else {
                            return
                        }
                        XCTAssertEqual(object.nestedCollection.count, count)
                        expectation.fulfill()
                    })


                    print("111111")
//                    let group: DispatchGroup = DispatchGroup()
//                    let queue: DispatchQueue = DispatchQueue(label: "Dispatch.Queue")
//                    let count: Int = 5
//                    queue.async {
//                        group.enter()
//                        CollectionObject.get(ref!.documentID, block: { (object, _) in
//                            guard let object: CollectionObject = object else {
//                                return
//                            }
//                            object.nestedCollection.query.dataSource().onCompleted({ (_, items) in
//                                for (index, item) in items.enumerated() {
//                                    group.enter()
//                                    object.nestedCollection.remove(item, block: { (error) in
//                                        XCTAssertEqual(object.nestedCollection.count, (count - (index + 1)))
//                                        CollectionObject.get(ref!.documentID, block: { (object, _) in
//                                            guard let object: CollectionObject = object else {
//                                                return
//                                            }
//                                            print(object.nestedCollection.count)
//                                            XCTAssertEqual(object.nestedCollection.count, (count - (index + 1)))
//                                            group.leave()
//                                        })
//                                    })
//                                }
//                                group.leave()
//                            }).get()
//                        })
//                    }
//                    group.notify(queue: .main, execute: {
//                        expectation.fulfill()
//                    })
//                    group.wait()
                })
                group.wait(timeout: DispatchTime.distantFuture)
            })
        }
        self.wait(for: [expectation], timeout: 20)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
