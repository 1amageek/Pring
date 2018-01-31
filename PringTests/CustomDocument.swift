//
//  CustomDocument.swift
//  PringTests
//
//  Created by 1amageek on 2018/01/31.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring

@objcMembers
class CustomDocument: Object {

    open override class var modelVersion: Int {
        return 2
    }

    open override class var modelName: String {
        return "custom"
    }
}
