//
//  PringInheritTest.swift
//  PringTests
//
//  Created by Shunpei Kobayashi on 2019/01/13.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
//@testable import Pring
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

class PringSubclassTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }
    
    func testCustomDocument() {
        _ = FirebaseTest.shared
        let expectation: XCTestExpectation = XCTestExpectation()
        let document: CustomDocument = SubclassCustomDocument()
        document.save { _, _ in
            SubclassCustomDocument.get(document.id, block: { (document, _) in
                XCTAssertTrue(document!.reference.path.contains("custom"))
                XCTAssertTrue(document!.reference.path.contains("2"))
                document?.delete({ (_) in
                    SubclassCustomDocument.get(document!.id, block: { (document, _) in
                        XCTAssertNil(document)
                        expectation.fulfill()
                    })
                })
                expectation.fulfill()
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testFiles() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Files")
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        
        document.file0 = File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png)
        document.file1 = File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png)
        document.file2 = File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png)
        
        document.file0?.additionalData = [
            "text": "test",
            "number": 0
        ]
        
        let tasks = document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                
                let file0: File = document.file0!
                
                XCTAssertEqual(file0.additionalData!["text"] as! String, "test")
                XCTAssertEqual(file0.additionalData!["number"] as! Int, 0)
                
                XCTAssertNotNil(document.file0?.downloadURL)
                XCTAssertNotNil(document.file1?.downloadURL)
                XCTAssertNotNil(document.file2?.downloadURL)
                
                let ref0 = document.file0?.ref
                let ref1 = document.file1?.ref
                let ref2 = document.file2?.ref
                
                ref0?.getData(maxSize: 1000000, completion: { (data, error) in
                    XCTAssertNotNil(data)
                    ref1?.getData(maxSize: 1000000, completion: { (data, error) in
                        XCTAssertNotNil(data)
                        ref2?.getData(maxSize: 1000000, completion: { (data, error) in
                            XCTAssertNotNil(data)
                            document.file0 = File.delete()
                            document.file1 = File.delete()
                            document.file2 = File.delete()
                            document.update({ (error) in
                                SubclassMultipleFilesDocument.get(ref!.documentID, block: { (doc, error) in
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
        }
        XCTAssertEqual(tasks.count, 3)
        self.wait(for: [expectation], timeout: 30)
    }
    
    func testFileArray() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Files")
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        
        let file: File = File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png)
        
        
        
        file.additionalData = [
            "text": "test",
            "number": 0
        ]
        
        document.fileArray.append(file)
        document.fileArray.append(File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png))
        document.fileArray.append(File(data: SubclassMultipleFilesDocument.image().pngData()!, mimeType: .png))
        
        let tasks = document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                XCTAssertNotNil(document)
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                
                let file0: File = document.fileArray.first!
                
                XCTAssertEqual(file0.additionalData!["text"] as! String, "test")
                XCTAssertEqual(file0.additionalData!["number"] as! Int, 0)
                
                let ref0 = document.fileArray[0].ref
                let ref1 = document.fileArray[1].ref
                let ref2 = document.fileArray[2].ref
                
                ref0?.getData(maxSize: 1000000, completion: { (data, error) in
                    XCTAssertNotNil(data)
                    ref1?.getData(maxSize: 1000000, completion: { (data, error) in
                        XCTAssertNotNil(data)
                        ref2?.getData(maxSize: 1000000, completion: { (data, error) in
                            XCTAssertNotNil(data)
                            document.fileArray = []
                            document.update({ (error) in
                                SubclassMultipleFilesDocument.get(ref!.documentID, block: { (doc, error) in
                                    guard let doc: SubclassMultipleFilesDocument = doc else {
                                        return
                                    }
                                    XCTAssertNotNil(doc)
                                    XCTAssertEqual(doc.fileArray.count, 0)
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
        }
        XCTAssertEqual(tasks.count, 3)
        self.wait(for: [expectation], timeout: 30)
    }
    
    func testNestedFilesSave() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Nested File delete")
        
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        let item: SubclassMultipleFilesNestedItem = SubclassMultipleFilesNestedItem()
        item.file = File(data: SubclassMultipleFilesNestedItem.image().pngData()!, mimeType: .png)
        document.files.insert(item as MultipleFilesNestedItem)
        let id: String = item.id
        
        document.save { (ref, error) in
            XCTAssertNotNil(item.file?.downloadURL)
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: SubclassMultipleFilesDocument = document else {
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
    
    func testNestedFilesUpdate() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Nested File delete")
        
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                XCTAssertNotNil(document)
                
                let item: MultipleFilesNestedItem = MultipleFilesNestedItem()
                item.file = File(data: MultipleFilesNestedItem.image().pngData()!, mimeType: .png)
                document.files.insert(item)
                let id: String = item.id
                document.update({ _ in
                    XCTAssertNotNil(item.file?.downloadURL)
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
            })
        }
        
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testNestedObjectUpdate() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Nested File delete")
        let nestedItem = SubclassNestedItem()
        nestedItem.item = SubclassNestedItem()
        nestedItem.save { (ref, error) in
            SubclassNestedItem.get(ref!.documentID, block: { (item, error) in
                guard let item: SubclassNestedItem = item else {
                    return
                }
                XCTAssertNotNil(item.item)
                item.item?.array = ["nested2"]
                item.nonOptionalItem.int = 100
                item.update({ _ in
                    XCTAssertNotNil(item.item)
                    SubclassNestedItem.get(ref!.documentID, block: { (item2, error) in
                        XCTAssertEqual("nested2", item2?.item?.array.first)
                        XCTAssertEqual(100, item2?.nonOptionalItem.int)
                        expectation.fulfill()
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testReferenceShallowFile() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Reference Shallow File")
        
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        let item: SubclassMultipleFilesShallowPathItem = SubclassMultipleFilesShallowPathItem()
        item.file = File(data: SubclassMultipleFilesShallowPathItem.image().pngData()!, mimeType: .png)
        document.subReferenceShallowFile.set(item)
        
        document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                XCTAssertNotNil(document)
                document.subReferenceShallowFile.get({ (item, error) in
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
    
    func testRelationShallowFile() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Relation Shallow File")
        
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        let item: SubclassMultipleFilesShallowPathItem = SubclassMultipleFilesShallowPathItem()
        item.file = File(data: SubclassMultipleFilesShallowPathItem.image().pngData()!, mimeType: .png)
        document.subRelationShallowFile.set(item)
        
        document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                XCTAssertNotNil(document)
                document.subRelationShallowFile.get({ (item, error) in
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
    
    func testShallowFiles() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Shallow File delete")
        
        let document: SubclassMultipleFilesDocument = SubclassMultipleFilesDocument()
        let item: MultipleFilesShallowPathItem = MultipleFilesShallowPathItem()
        item.file = File(data: MultipleFilesShallowPathItem.image().pngData()!, mimeType: .png)
        document.shallowFiles.insert(item)
        let id: String = item.id
        
        document.save { (ref, error) in
            SubclassMultipleFilesDocument.get(ref!.documentID, block: { (document, error) in
                guard let document: SubclassMultipleFilesDocument = document else {
                    return
                }
                XCTAssertNotNil(document)
                document.shallowFiles.get(id, block: { (item, error) in
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
    
    func testDocumentMemoryLeak() {
        
        weak var weakDocument: SubclassTestDocument?
        
        do {
            let document: SubclassTestDocument = SubclassTestDocument()
            document.refItem.parent = document
            weakDocument = document
            document.rawValue
        }
        
        XCTAssertNil(weakDocument)
    }
    
    func testDocumentMemory() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test File")
        weak var weakDocument: SubclassTestDocument?
        
        do {
            let document: SubclassTestDocument = SubclassTestDocument()
            weakDocument = document
            document.save({ (ref, error) in
                SubclassTestDocument.get(ref!.documentID, block: { (document, error) in
                    let file1: File = File(data: SubclassTestDocument.image1().pngData()!, mimeType: .png)
                    document?.file = file1
                    document?.update({ (error) in
                        SubclassTestDocument.get(ref!.documentID, block: { (document, error) in
                            expectation.fulfill()
                        })
                    })
                })
                expectation.fulfill()
            })
        }
        
        self.wait(for: [expectation], timeout: 10)
        XCTAssertNil(weakDocument)
    }
    
    func testOptionalDocumentMemory() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test File")
        weak var weakDocument: TestOptionalDocument?
        
        do {
            let document: TestOptionalDocument = TestOptionalDocument()
            weakDocument = document
            document.save({ (ref, error) in
                TestOptionalDocument.get(ref!.documentID, block: { (document, error) in
                    let file1: File = File(data: TestDocument.image1().pngData()!, mimeType: .png)
                    document?.file = file1
                    document?.update({ (error) in
                        TestOptionalDocument.get(ref!.documentID, block: { (document, error) in
                            expectation.fulfill()
                        })
                    })
                })
            })
        }
        
        self.wait(for: [expectation], timeout: 10)
        XCTAssertNil(weakDocument)
    }
    
    func testSubCollectionInsetBeforeSave() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test SubCollection")
        let document: SubclassTestDocument = SubclassTestDocument()
        let nestedItem: SubclassNestedItem = SubclassNestedItem()
        document.subCollection.insert(nestedItem)
        document.save { (ref, error) in
            XCTAssertEqual(nestedItem.isSaved, true)
            XCTAssertEqual(document.isSaved, true)
            XCTAssertEqual(document.subCollection.first?.string, "nested")
            SubclassTestDocument.get(ref!.documentID, block: { (document, error) in
                document?.subCollection.get(nestedItem.id, block: { (item, error) in
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
    
    func testSubCollectionInsetAfterSave() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test SubCollection")
        let document: SubclassTestDocument = SubclassTestDocument()
        let nestedItem: SubclassNestedItem = SubclassNestedItem()
        document.save { (ref, error) in
            XCTAssertEqual(document.isSaved, true)
            document.subCollection.insert(nestedItem)
            document.update({ (error) in
                XCTAssertEqual(nestedItem.isSaved, true)
                XCTAssertEqual(document.subCollection.first?.string, "nested")
                SubclassTestDocument.get(ref!.documentID, block: { (document, error) in
                    document?.subCollection.get(nestedItem.id, block: { (item, error) in
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
            })
        }
        self.wait(for: [expectation], timeout: 15)
    }
    
    var dataSource: DataSource<SubclassDataSourceItem>?
    
    func testDataSource() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test DataSource")
        
        let group: DispatchGroup = DispatchGroup()
        let queue: DispatchQueue = DispatchQueue(label: "Dispatch.Queue")
        let count: Int = 10
        queue.async {
            (0..<count).forEach({ (index) in
                group.enter()
                let document: SubclassDataSourceItem = SubclassDataSourceItem()
                document.index = index
                document.save({ (ref, error) in
                    group.leave()
                })
            })
            group.notify(queue: .main, execute: {
                self.dataSource = SubclassDataSourceItem.query.dataSource().on({ (snapshot, change) in
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
    
    func testReferenceCollection() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test ReferenceCollection")
        let object: SubclassCollectionObject = SubclassCollectionObject()
        
        object.save { (ref, _) in
            SubclassCollectionObject.get(ref!.documentID, block: { (object, _) in
                let obj: SubclassCollectionObject = SubclassCollectionObject()
                object?.subReferenceCollection.insert(obj)
                object?.update({ (_) in
                    SubclassCollectionObject.get(ref!.documentID, block: { (object, _) in
                        guard let object: SubclassCollectionObject = object else {
                            return
                        }
                        object.subReferenceCollection.query.dataSource().onCompleted({ (_, items) in
                            XCTAssertEqual(items.count, 1)
                            expectation.fulfill()
                        }).get()
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 20)
    }
    
    func testReference() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "Test Reference")
        let object: SubclassTestDocument = SubclassTestDocument()
        let item: SubclassReferenceItem = SubclassReferenceItem()
        
        object.refItem.set(item)
        object.save { (ref, _) in
            SubclassTestDocument.get(ref!.documentID, block: { (object, _) in
                XCTAssertEqual(object?.refItem.id!, item.id)
                let newItem: SubclassReferenceItem = SubclassReferenceItem()
                object?.refItem.set(newItem)
                object?.update({ (_) in
                    SubclassTestDocument.get(ref!.documentID, block: { (object, _) in
                        XCTAssertEqual(object?.refItem.id!, newItem.id)
                        object?.delete({ (_) in
                            newItem.delete({ (_) in
                                item.delete({ (_) in
                                    expectation.fulfill()
                                })
                            })
                        })
                    })
                })
            })
        }
        self.wait(for: [expectation], timeout: 20)
    }
    
}
