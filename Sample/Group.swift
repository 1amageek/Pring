//
//  Group.swift
//  Sample
//
//  Created by 1amageek on 2017/11/29.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation

@objcMembers
class Group: Object {

    enum Media: String, AnyContentType {
        case photo
    }

    dynamic var name: String?

//    dynamic var owner: Reference<User>?
//
//    dynamic var media: MultipleReference<Media>?
}
