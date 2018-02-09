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

    func testReferneceCollectionLoopRefBeforeSaved() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        user0.name = "user0"
        user1.name = "user1"
        user0.followers.insert(user1)
        user1.followees.insert(user0)
        user0.save { (ref, error) in
            XCTAssertEqual(user0.followers.count, 1)
            user0.followers.query.dataSource().onCompleted({ (_, users) in
                XCTAssertEqual(users.count, 1)
                user1.followees.query.dataSource().onCompleted({ (_, users) in
                    XCTAssertEqual(users.count, 1)
                    expectation.fulfill()
                }).get()
            }).get()
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testReferneceCollectionLoopRefAfterSaved0() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        user0.name = "user0"
        user1.name = "user1"
        user0.save { _, _ in
            user1.save { _,_ in
                user0.followers.insert(user1)
                user1.followees.insert(user0)
                user0.update { _ in
                    user0.followers.query.dataSource().onCompleted({ (_, users) in
                        XCTAssertEqual(users.count, 1)
                        user1.followees.query.dataSource().onCompleted({ (_, users) in
                            XCTAssertEqual(users.count, 1)
                            expectation.fulfill()
                        }).get()
                    }).get()
                }
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testReferneceCollectionLoopRefAfterSaved1() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let user1: User = User()
        user0.name = "user0"
        user1.name = "user1"
        user0.save { _, _ in
            user1.save { _,_ in
                user0.followers.insert(user1)
                user1.followees.insert(user0)
                user1.update { _ in
                    user0.followers.query.dataSource().onCompleted({ (_, users) in
                        XCTAssertEqual(users.count, 1)
                        user1.followees.query.dataSource().onCompleted({ (_, users) in
                            XCTAssertEqual(users.count, 1)
                            expectation.fulfill()
                        }).get()
                    }).get()
                }
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }


    func testReferneceCollectionLoopRefAfterSaveWithCount() {
        let expectation: XCTestExpectation = XCTestExpectation()

        let waitQueue: DispatchQueue = DispatchQueue(label: "test.wait.queue")
        let queue: DispatchQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group: DispatchGroup = DispatchGroup()
        let count: Int = 5

        let user: User = User()
        user.name = "main"
        user.save { (_, _) in
            waitQueue.async {
                (0..<count).forEach({ (index) in
                    group.enter()
                    queue.async {
                        let follwer: User = User()
                        follwer.name = "follow_\(index)"
                        follwer.save { _, _ in
                            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                                let userDocument: DocumentSnapshot
                                let follwerDocument: DocumentSnapshot
                                do {
                                    try userDocument = transaction.getDocument(user.reference)
                                    try follwerDocument = transaction.getDocument(follwer.reference)
                                } catch let fetchError as NSError {
                                    errorPointer?.pointee = fetchError
                                    return nil
                                }
                                guard let userData: [String: Any] = userDocument.data() else {
                                    return nil
                                }
                                guard let follwerData: [String: Any] = follwerDocument.data() else {
                                    return nil
                                }
                                let followerCount: Int = (userData["followerCount"] as? Int ?? 0) + 1
                                let followeeCount: Int = (follwerData["followeeCount"] as? Int ?? 0) + 1
                                transaction.updateData(["followerCount": followerCount], forDocument: user.reference)
                                transaction.updateData(["followeeCount": followeeCount], forDocument: follwer.reference)
                                return nil
                            }, completion: { (_, _) in
                                user.followers.insert(follwer)
                                follwer.followees.insert(user)
                                follwer.update { _ in
                                    user.followers.query.dataSource().onCompleted({ (_, users) in
                                        follwer.followees.query.dataSource().onCompleted({ (_, users) in
                                            XCTAssertEqual(users.count, 1)
                                            group.leave()
                                        }).get()
                                    }).get()
                                }
                            })
                        }
                    }
                })
                group.notify(queue: .main, execute: {
                    User.get(user.id, block: { (user, _) in
                        XCTAssertEqual(user?.followerCount, count)
                        expectation.fulfill()
                    })
                })
                group.wait()
            }
        }
        self.wait(for: [expectation], timeout: 15)
    }

    func testReferneceCollectionLoopRefAfterSaveWithCountWhenObjectInit() {
        let expectation: XCTestExpectation = XCTestExpectation()

        let waitQueue: DispatchQueue = DispatchQueue(label: "test.wait.queue")
        let queue: DispatchQueue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group: DispatchGroup = DispatchGroup()
        let count: Int = 2

        let user: User = User()
        let userID: String = user.id
        user.name = "main"
        user.save { (_, _) in
            waitQueue.async {
                (0..<count).forEach({ (index) in
                    group.enter()
                    queue.async {
                        let user: User = User(id: userID, value: [:])
                        let follwer: User = User()
                        follwer.name = "follow_\(index)"
                        follwer.save { _, _ in
                            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                                let userDocument: DocumentSnapshot
                                let follwerDocument: DocumentSnapshot
                                do {
                                    try userDocument = transaction.getDocument(user.reference)
                                    try follwerDocument = transaction.getDocument(follwer.reference)
                                } catch let fetchError as NSError {
                                    errorPointer?.pointee = fetchError
                                    return nil
                                }
                                guard let userData: [String: Any] = userDocument.data() else {
                                    return nil
                                }
                                guard let follwerData: [String: Any] = follwerDocument.data() else {
                                    return nil
                                }
                                let followerCount: Int = (userData["followerCount"] as? Int ?? 0) + 1
                                let followeeCount: Int = (follwerData["followeeCount"] as? Int ?? 0) + 1
                                transaction.updateData(["followerCount": followerCount], forDocument: user.reference)
                                transaction.updateData(["followeeCount": followeeCount], forDocument: follwer.reference)
                                return nil
                            }, completion: { (_, _) in
                                user.followers.insert(follwer)
                                follwer.followees.insert(user)
                                follwer.update { _ in
                                    user.followers.query.dataSource().onCompleted({ (_, users) in
                                        follwer.followees.query.dataSource().onCompleted({ (_, users) in
                                            XCTAssertEqual(users.count, 1)
                                            group.leave()
                                        }).get()
                                    }).get()
                                }
                            })
                        }
                    }
                })
                group.notify(queue: .main, execute: {
                    User.get(user.id, block: { (user, _) in
                        XCTAssertEqual(user?.followerCount, count)
                        expectation.fulfill()
                    })
                })
                group.wait()
            }
        }
        self.wait(for: [expectation], timeout: 20)
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

    func testNestedCollectionUpdate() {
        let expectation: XCTestExpectation = XCTestExpectation()
        let user0: User = User()
        let item0: Item = Item()

        user0.name = "user0"
        item0.name = "item0"

        user0.items.insert(item0)
        user0.save { (ref, error) in
            item0.name = "update"
            item0.update({ (_) in
                user0.items.query.dataSource().onCompleted({ (_, items) in
                    XCTAssertEqual(items.count, 1)
                    XCTAssertEqual(items.first!.name, "update")
                    user0.items.remove(item0)
                    user0.update({ (_) in
                        user0.items.query.dataSource().onCompleted({ (_, items) in
                            XCTAssertEqual(items.count, 0)
                            user0.delete({ (_) in
                                expectation.fulfill()
                            })
                        }).get()
                    })
                }).get()
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
}
