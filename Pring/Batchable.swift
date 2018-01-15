//
//  Batchable.swift
//  Pring
//
//  Created by 1amageek on 2017/11/22.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum BatchType {
    case save
    case update
    case delete
}

public protocol Batchable {

    @discardableResult
    func pack(_ type: BatchType, batch: WriteBatch?) -> WriteBatch

    func batchCompletion()
}

extension WriteBatch {

    @discardableResult
    public func add(_ type: BatchType, object: Object) -> WriteBatch {
        return object.pack(type, batch: self)
    }
}
