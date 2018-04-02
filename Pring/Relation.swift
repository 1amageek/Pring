//
//  Relation.swift
//  Pring
//
//  Created by 1amageek on 2018/02/27.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol AnyRelation: HasParent, StorageLinkable {

    var id: String? { get set }

    var value: String? { get }
}

extension AnyRelation where Self: HasDocument {

    public func shouldUploadFiles(_ id: String) -> Bool {
        return self.object?.shouldUploadFiles(id) ?? false
    }

    public func saveFiles(_ id: String, container: UploadContainer?, block: ((Error?) -> Void)?) -> [String : StorageUploadTask] {
        let uploadContainer: UploadContainer = container ?? UploadContainer()
        self.object?.saveFiles(id, container: uploadContainer, block: nil)
        return uploadContainer.tasks
    }

    public func deleteFiles(_ id: String, container: DeleteContainer?, block: ((Error?) -> Void)?) {
        let deleteContainer: DeleteContainer = container ?? DeleteContainer()
        self.deleteFiles(id, container: deleteContainer, block: nil)
    }
}

public class Relation<T: Document>: AnyRelation, HasDocument, Batchable {

    public typealias ContentType = T

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    public var batchID: String?

    public var object: ContentType?

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

    private var _hash: Int?

    public func pack(_ type: BatchType, batch: WriteBatch) -> WriteBatch {
        if self._hash == batch.hash {
            return batch
        }
        self._hash = batch.hash
        switch type {
        case .save:
            if let document: ContentType = self.object {
                if !document.isSaved {
                    document.pack(.save, batch: batch)
                } else {
                    document.pack(.update, batch: batch)
                }
            }
        case .update:
            if let document = self.object {
                if !document.isSaved {
                    document.pack(.save, batch: batch)
                } else {
                    document.pack(.update, batch: batch)
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
