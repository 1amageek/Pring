//
//  Reference.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol HasParent {

    var parent: Object? { get }

    var key: String? { get }

    func setParent(_ object: Object, forKey key: String)
}

public protocol HasDocument {

    associatedtype ContentType: Document

    var object: ContentType? { get set }
}

public protocol AnyReference: HasParent, StorageLinkable {

    var id: String? { get }

    var documentReference: DocumentReference? { get set }

    var value: DocumentReference? { get }
}

extension AnyReference where Self: HasDocument {
    
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

public class Reference<T: Document>: AnyReference, HasDocument, Batchable {

    public typealias ContentType = T

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    public var batchID: String?

    public var object: ContentType?

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

    deinit {
        self.parent = nil
    }
}

