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
                        user?.followers.remove(user1.id)
                        print("!!!!!!!!!!!!")
                        user?.update({ (_) in
                            user?.followers.query.dataSource().onCompleted({ (_, users) in
                                XCTAssertEqual(users.count, 0)
                                expectation.fulfill()
                            }).get()
                        })
                    }).get()
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
}
