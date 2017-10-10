//
//  User.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Pring

@objcMembers
class User: Object {

    var name: String?
    var thumbnailImage: File?
    var followers: Relation<User> = []
}
