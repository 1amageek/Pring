//
//  CollectionObject.swift
//  PringTests
//
//  Created by 1amageek on 2017/11/12.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Pring
import Firebase
import FirebaseFirestore

@objcMembers
class CollectionObject: Object {

    let nestedCollection: NestedCollection<NestedItem> = []
    let referenceCollection: ReferenceCollection<CollectionObject> = []
    let countableNestedCollection: CountableNestedCollection<NestedItem> = []
    let countableReferenceCollection: CountableReferenceCollection<CollectionObject> = []
}
