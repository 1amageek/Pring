//
//  Reference.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol HasParent {

    weak var parent: Object? { get }

    var key: String? { get }

    func setParent(_ object: Object, forKey key: String)
}

public protocol AnyReference: HasParent {

    var id: String? { get }

    var documentReference: DocumentReference? { get set }

    var value: DocumentReference? { get }
}

public class Reference<T: Document>: AnyReference, Batchable {

    public typealias ContentType = T

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    public var batchID: String?

    public private(set) var object: ContentType?

    public var documentReference: DocumentReference?

    public var id: String? {
        return self.object?.id ?? self.documentReference?.documentID
    }

    public var value: DocumentReference? {
        return self.object?.reference ?? self.documentReference
    }

    public init() { }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    public func set(_ object: ContentType) {
        self.object = object
        guard let key: String = self.key, let value: DocumentReference = self.value else {
            return
        }
        if self.parent?.isObserving ?? false {
            self.parent?.update(key: key, value: value)
        }
    }

    public func delete() {
        self.object = nil
        guard let key: String = self.key else {
            return
        }
        if self.parent?.isObserving ?? false {
            self.parent?.update(key: key, value: FieldValue.delete())
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
