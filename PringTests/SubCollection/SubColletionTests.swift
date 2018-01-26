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

    func testReferenceCollection() {

        let user0: User = User()
        let user1: User = User()

        let user0ID: String = user0.id
        let user1ID: String = user1.id

        user0.followers.insert(user1)
//        user1.followees.insert(user0)

        let expectation: XCTestExpectation = XCTestExpectation()
        user0.save { (ref, error) in
            User.get(user1ID, block: { (user, _) in
                XCTAssertNotNil(user)
                XCTAssertEqual(user?.name, "user")
                user?.name = "update"
                user?.update({ (error) in
                    User.get(user1ID, block: { (user, _) in
                        XCTAssertNotNil(user)
                        XCTAssertEqual(user?.name, "update")
                    })
                    expectation.fulfill()
                })
            })
        }
        self.wait(for: [expectation], timeout: 10)
    }
    
}
