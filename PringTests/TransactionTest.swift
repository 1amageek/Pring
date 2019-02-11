//
//  TransactionTest.swift
//  PringTests
//
//  Created by 1amageek on 2019/02/04.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import Firebase

//class TransactionTest: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        _ = FirebaseTest.shared
//    }
//
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    let numberOfActions: Int = 10
//
//    func testTransaction() {
//        let expectation: XCTestExpectation = XCTestExpectation(description: "")
//        let db: Firestore = Firestore.firestore()
//        let batch: WriteBatch = db.batch()
//        let numberOfShards: Int = 5
//        (0..<numberOfShards).forEach { (index) in
//            batch.setData(["count": 0], forDocument: db.collection("shards").document("\(index)"), merge: true)
//        }
//
//        batch.commit { (error) in
//
//            let group: DispatchGroup = DispatchGroup()
//            let queue: DispatchQueue = DispatchQueue(label: "test.queue")
//            queue.async {
//
//                (0..<self.numberOfActions).forEach({ (index) in
//                    group.enter()
//                    let shardId = Int(arc4random_uniform(UInt32(numberOfShards)))
//                    let shardRef = db.collection("shards").document(String(shardId))
//                    db.runTransaction({ (transaction, errorPointer) -> Any? in
//
//                        var count: Int = 0
//                        var shardCount: Int = 0
//
//                        (0..<numberOfShards).forEach({ (index) in
//                            do {
//                                let shardRef = db.collection("shards").document(String(index))
//                                let shardData = try transaction.getDocument(shardRef).data() ?? [:]
////                                let _shardCount = shardData["count"] as! Int
////                                count += _shardCount
////
////                                if (shardId == index) {
////                                    shardCount = _shardCount
////                                }
//
//                            }  catch let fetchError as NSError {
//                                errorPointer?.pointee = fetchError
//                                return
//                            }
//                        })
////                        do {
////                            let shardData = try transaction.getDocument(shardRef).data() ?? [:]
////                            shardCount = shardData["count"] as! Int
////                        } catch {
////                            // Error getting shard data
////                            // ...
////                        }
//                        let nextCount: Int = shardCount + 1
////                        if (count > 10) {
////                            let error = NSError(
////                                domain: "AppErrorDomain",
////                                code: -2,
////                                userInfo: [NSLocalizedDescriptionKey: "Population too big"]
////                            )
////                            errorPointer?.pointee = error
////                            return nil
////                        }
//
//                        transaction.updateData(["count": nextCount], forDocument: shardRef)
//                        return nil
//                    }) { (object, error) in
//                        if let error = error {
//                            print(error)
//                            return
//                        }
//                        group.leave()
//                    }
//                })
//
//                group.notify(queue: .main, execute: {
//                    print("***********")
//                    expectation.fulfill()
//                })
//                group.wait()
//            }
//
//        }
//
//        self.wait(for: [expectation], timeout: 30)
//    }
//}
