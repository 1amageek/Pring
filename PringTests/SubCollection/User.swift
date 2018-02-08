//
//  User.swift
//  PringTests
//
//  Created by 1amageek on 2018/01/27.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit
import Pring

@objcMembers
class User: Object {

    dynamic var name: String = "user"
    dynamic var file: File?

    dynamic var followerCount: Int = 0
    dynamic var followeeCount: Int = 0

    let followers: ReferenceCollection<User>  = []
    let followees: ReferenceCollection<User>  = []
    let items: NestedCollection<Item> = []
}
