//
//  ReferenceCollection.swift
//  Pring
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol SubCollection {

    var path: String { get }

    var reference: CollectionReference { get }

    var key: String? { get set }

    var parent: Object? { get set }

    var value: [AnyHashable: Any] { get }

    var references: [AnyHashable: Any] { get }

    func setValue(_ value: Any?, forKey key: String)

    @discardableResult
    func pack(_ batch: WriteBatch?) -> WriteBatch
}
