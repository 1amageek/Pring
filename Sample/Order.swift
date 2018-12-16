//
//  Order.swift
//  Sample
//
//  Created by 1amageek on 2018/12/16.
//  Copyright © 2018 Stamp Inc. All rights reserved.
//

import Pring

@objcMembers
class Order: Object {
    dynamic var name: String?
    let items: List<OrderItem> = []
}
