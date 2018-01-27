//
//  SubColletionTests.swift
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

class SubColletionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testReferenceCollectionInsert() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        let user2: User = User()

        user0.name = "user0"
        user1.name = "user1"
        user2.name = "user2"

        let user0ID: String = user0.id
        user0.followers.insert(user1)
        user0.save { (ref, error) in
            user0.followers.insert(user2)
            user0.update({ (_) in
                XCTAssertEqual(user0.followers.count, 2)
                User.get(user0ID, block: { (user, _) in
                    user?.followers.query.dataSource().onCompleted({ (_, users) in
                        XCTAssertEqual(users.count, 2)
                        user?.followers.remove(user2)
                        user?.followers.remove(user1.id, hard: true)
                        user?.update({ (_) in
                            user?.followers.query.dataSource().onCompleted({ (_, users) in
                                XCTAssertEqual(users.count, 0)
                                User.get(user1.id, block: { (user, error) in
                                    XCTAssertNil(user)
                                    expectation.fulfill()
                                })
                            }).get()
                        })
                    }).get()
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testReferenceCollectionUpdate() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()

        user0.name = "user0"
        user1.name = "user1"

        var updatedAt: Date = Date()

        user0.followers.insert(user1)
        user0.save { (ref, error) in
            user0.update({ (_) in
                XCTAssertEqual(user0.followers.count, 1)
                user0.followers.query.dataSource().onCompleted({ (snapshot, _) in
                    let document = snapshot!.documents.first
                    updatedAt = document?.data()["updatedAt"] as! Date
                    user0.followers.insert(user1)
                    user0.update({ (_) in
                        XCTAssertEqual(user0.followers.count, 1)
                        user0.followers.query.dataSource().onCompleted({ (snapshot, _) in
                            let document = snapshot!.documents.first
                            XCTAssertTrue(updatedAt < document?.data()["updatedAt"] as! Date)
                            let batch = Firestore.firestore().batch()
                            user0.followers.delete(id: user1.id)
                            user0.update({ (_) in
                                batch.add(.delete, object: user0)
                                batch.add(.delete, object: user1)
                                batch.commit(completion: { (_) in
                                    expectation.fulfill()
                                })
                            })
                        }).get()
                    })
                }).get()
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }


    func testReferenceCollectionDelete() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        user0.name = "user0"
        user1.name = "user1"
        user0.followers.insert(user1)
        user0.save { (ref, error) in
            XCTAssertEqual(user0.followers.count, 1)
            user0.followers.remove(user1.id)
            user0.update({ (_) in
                XCTAssertEqual(user0.followers.count, 0)
                user0.followers.query.dataSource().onCompleted({ (_, users) in
                    XCTAssertEqual(users.count, 0)
                    User.get(user1.id, block: { (user, _) in
                        XCTAssertNotNil(user)
                        user0.delete { _ in
                            expectation.fulfill()
                        }
                    })
                }).get()
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testReferenceCollectionHardDelete() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        user0.name = "user0"
        user1.name = "user1"
        user0.followers.insert(user1)
        user0.save { (ref, error) in
            XCTAssertEqual(user0.followers.count, 1)
            user0.followers.remove(user1.id, hard: true)
            user0.update({ (_) in
                XCTAssertEqual(user0.followers.count, 0)
                user0.followers.query.dataSource().onCompleted({ (_, users) in
                    XCTAssertEqual(users.count, 0)
                    User.get(user1.id, block: { (user, _) in
                        XCTAssertNil(user)
                        user0.delete { _ in
                            expectation.fulfill()
                        }
                    })
                }).get()
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testNestedCollectionInsert() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let item0: Item = Item()
        let item1: Item = Item()

        user0.name = "user0"
        item0.name = "item0"
        item1.name = "item1"
        user0.items.insert(item0)
        user0.save { (ref, error) in
            user0.items.insert(item1)
            user0.update({ (_) in
                XCTAssertEqual(user0.items.count, 2)
                User.get(user0.id, block: { (user, _) in
                    user?.items.query.dataSource().onCompleted({ (_, items) in
                        XCTAssertEqual(items.count, 2)
                        user?.items.remove(item0)
                        user?.items.remove(item1.id)
                        XCTAssertEqual(user?.items.count, 0)
                        user?.update({ (_) in
                            user?.items.query.dataSource().onCompleted({ (_, items) in
                                XCTAssertEqual(items.count, 0)
                                user?.delete({ (_) in
                                    expectation.fulfill()
                                })
                            }).get()
                        })
                    }).get()
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
}
