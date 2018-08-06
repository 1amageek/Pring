//
//  Collecor.swift
//  Sample
//
//  Created by 1amageek on 2017/11/13.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import Pring

@objcMembers
class Collector: Object {

    let nestedCollection: NestedCollection<Item> = []
    let referenceCollection: ReferenceCollection<Item> = []
}
