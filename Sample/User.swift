//
//  User.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation

@objcMembers
class User: Object {

    dynamic var name: String? = "NULL"
    dynamic var age: Int = 0
    dynamic var followers: ReferenceCollection<User> = []
    dynamic var items: NestedCollection<Item> = []
//    var thumbnailImage: File?
//    var followers: Relation<User> = []
}

//class Follower: Relation<User> {
//
//}

