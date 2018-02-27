//
//  Relation.swift
//  Pring
//
//  Created by 1amageek on 2018/02/27.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol AnyRelation: HasParent {

    var id: String? { get set }

    var value: String? { get }
}


public class Relation<T: Document>: AnyRelation, Batchable {

    public typealias ContentType = T

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    public var batchID: String?

    public private(set) var object: ContentType?

    private var _id: String?

    public var id: String? {
        get {
            return self.object?.id ?? _id
        }
        set(newValue) {
            _id = newValue
        }
    }

    public var value: String? {
        return self.id
    }

    public init() { }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    public func set(_ object: ContentType) {
        self.object = object
        guard let key: String = self.key, let value: String = self.value else {
            return
        }
        guard let parent = self.parent else {
            return
        }
        if parent.isSaved {
            parent.update(key: key, value: value)
        }
    }

    public func delete() {
        self.object = nil
        guard let key: String = self.key else {
            return
        }
        guard let parent = self.parent else {
            return
        }
        if parent.isSaved {
            parent.update(key: key, value: FieldValue.delete())
        }
    }

    public func pack(_ type: BatchType, batch: WriteBatch) -> WriteBatch {
        switch type {
        case .save:
            if let document: ContentType = self.object {
                if !document.isSaved {
                    batch.setData(document.value as! [String : Any], forDocument: document.reference)
                }
            }
        case .update:
            if let document = self.object {
                if !document.isSaved {
                    batch.setData(document.value as! [String : Any], forDocument: document.reference)
                }
            }
        case .delete: break
        }
        return batch
    }


    public func batch(_ type: BatchType, completion ID: String) {
        self.object?.batch(type, completion: ID)
    }

    public func get(_ block: @escaping (ContentType?, Error?) -> Void) {
        guard let id: String = self.id else {
            block(nil, nil)
            return
        }
        ContentType.get(id) { (document, error) in
            self.object = document
            block(document, error)
        }
    }
}
