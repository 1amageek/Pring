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

    @discardableResult
    public override func pack(_ type: BatchType, batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        switch type {
        case .save:
            var value: [AnyHashable: Any] = [:]
            value[(\Object.createdAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
            value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
            _self.forEach { (document) in
                if !document.isSaved {
                    document.pack(.save, batch: batch)
                }
                let reference: DocumentReference = self.reference.document(document.id)
                batch.setData(value as! [String : Any], forDocument: reference)
            }
        case .update:
            var value: [AnyHashable: Any] = [:]
            value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
            _insertions.subtracting(_deletions).forEach({ (document) in
                if !document.isSaved {
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
        _self.append(newMember)
        if isSaved {
            _insertions.insert(newMember)
        }
    }

    /// Deletes the Object from the reference destination.
    public override func remove(_ member: Element) {
        if let index: Int = _self.index(of: member) {
            _self.remove(at: index)
        }
        if isSaved {
            _deletions.insert(member)
        }
    }
}

