//
//  ReferenceCollection.swift
//  Pring
//
//  Created by 1amageek on 2018/01/24.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public class ReferenceCollection<T: Document>: SubCollection<T> {

    internal var _hardDeletions: Set<T> = []

    @discardableResult
    public override func pack(_ type: BatchType, batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        switch type {
        case .save:
            var value: [AnyHashable: Any] = [:]
            _self.forEach { (document) in
                if T.shouldBeReplicated {
                    value = document.value
                }
                value[(\Object.createdAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                if !document.isSaved {
                    document.pack(.save, batch: batch)
                } else {
                    document.pack(.update, batch: batch)
                }
                let reference: DocumentReference = self.reference.document(document.id)
                batch.setData(value as! [String : Any], forDocument: reference)
            }
        case .update:
            var value: [AnyHashable: Any] = [:]
            _insertions.subtracting(_deletions).forEach({ (document) in
                if document.isSaved {
                    if T.shouldBeReplicated {
                        value = document.value
                    }
                    value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                    value[(\Object.createdAt)._kvcKeyPathString!] = document.createdAt
                    document.pack(.update, batch: batch)
                } else {
                    if T.shouldBeReplicated {
                        value = document.value
                    }
                    value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                    value[(\Object.createdAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                    document.pack(.save, batch: batch)
                }
                let reference: DocumentReference = self.reference.document(document.id)
                batch.setData(value as! [String : Any], forDocument: reference)
            })
            _deletions.subtracting(_insertions).forEach({ (document) in
                let reference: DocumentReference = self.reference.document(document.id)
                batch.deleteDocument(reference)
            })
            _hardDeletions.forEach({ (document) in
                batch.deleteDocument(document.reference)
            })
        case .delete:
            self.forEach { (document) in
                let reference: DocumentReference = self.reference.document(document.id)
                batch.deleteDocument(reference)
            }
        }
        return batch
    }

    // MARK: -

    /// Save the new Object.
    public override func insert(_ newMember: Element) {
        if !_self.contains(newMember) {
            _self.append(newMember)
        }
        _insertions.insert(newMember)
    }
    
    /// Deletes the Object from the reference destination.
    public func remove(_ member: Element, hard: Bool = false) {
        if let index: Int = _self.index(of: member) {
            _self.remove(at: index)
        }
        _deletions.insert(member)
        if hard {
            _hardDeletions.insert(member)
        }
    }

    /// Deletes the Document contained in SubCollection from ID.
    public func remove(_ id: String, hard: Bool = false) {
        let document: Element = Element(id: id)
        self.remove(document, hard: hard)
    }
}

