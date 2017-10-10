//
//  Document.swift
//  Pring
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

/**
 Firestore's Document Protocol
 */
public protocol Document: NSObjectProtocol {

    static var version: Int { get }

    static var modelName: String { get }

    static var path: String { get }

    static var reference: CollectionReference { get }

    static var storageRef: StorageReference { get }

    var path: String { get }

    var reference: DocumentReference { get }

    var id: String { get }

    var isListening: Bool { get }

    var rawValue: [AnyHashable: Any] { get }

    var value: [AnyHashable: Any] { get }

    init(snapshot: DocumentSnapshot)
    
    @discardableResult
    func pack(_ batch: WriteBatch?) -> WriteBatch
}

public extension Document {

    public static func get(_ id: String, block: @escaping (Self?, Error?) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot else {
                block(nil, error)
                return
            }
            let document: Self = Self(snapshot: snapshot)
            block(document, nil)
        }
    }

    public static func listen(_ id: String, block: @escaping (Self?, Error?) -> Void) -> FIRListenerRegistration {
        let options: DocumentListenOptions = DocumentListenOptions()
        return self.reference.document(id).addSnapshotListener(options: options) { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot else {
                block(nil, error)
                return
            }
            let document: Self = Self(snapshot: snapshot)
            block(document, nil)
        }
    }

    public static func listen(_ id: String, block: @escaping (Self?, Error?) -> Void) -> Disposer<Self> {
        return .init(.value(listen(id, block: block)))
    }
}
