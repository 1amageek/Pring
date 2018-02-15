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

    var batchID: String? { get set }

    @discardableResult
    func pack(_ type: BatchType, batch: WriteBatch) -> WriteBatch

    func batch(_ type: BatchType, completion batchID: String)
}

extension WriteBatch {

    @discardableResult
    public func add<T: Document>(_ type: BatchType, object: T) -> WriteBatch {
        return object.pack(type, batch: self)
    }
}
