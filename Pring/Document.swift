//
//  Document.swift
//  Pring
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

/**
 Firestore's Document Protocol
 */
public protocol Document: NSObjectProtocol, Hashable, StorageLinkable, Batchable {

    static var modelVersion: Int { get }

    static var modelName: String { get }

    static var path: String { get }

    static var reference: CollectionReference { get }

    static var storageRef: StorageReference { get }

    var reference: DocumentReference { get }

    var path: String { get }

    var id: String { get }

    var isListening: Bool { get }

    var rawValue: [AnyHashable: Any] { get }

    var value: [AnyHashable: Any] { get }

    var ignore: [String] { get }

    init(snapshot: DocumentSnapshot)
}

public extension Document {
    
    public var hasFiles: Bool {
        let mirror = Mirror(reflecting: self)
        for (_, child) in mirror.children.enumerated() {
            if let key: String = child.label {
                switch DataType(key: key, value: child.value) {
                case .file(_, _, _): return true
                case .collection(_, _, let collection): return collection.hasFiles
                default: break
                }
            }
        }
        return false
    }

    public func saveFiles(container: UploadContainer? = nil, block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {

        var uploadContainer: UploadContainer = container ?? UploadContainer()

        for (_, child) in Mirror(reflecting: self).children.enumerated() {

            guard let key: String = child.label else { break }
            if self.ignore.contains(key) { break }
            let value = child.value

            switch DataType(key: key, value: value) {
            case .file(let key, _, let file):
                file.parent = self as? Object
                file.key = key
                uploadContainer.group.enter()
                if let task: StorageUploadTask = file.save(key, completion: { (meta, error) in
                    defer {
                        uploadContainer.group.leave()
                    }
                    if let error: Error = error {
                        uploadContainer.error = error
                        return
                    }
                }) {
                    uploadContainer.tasks[key] = task
                }
            case .collection(_, _, let collection):
                collection.saveFiles(container: container, block: nil)
            default: break
            }

        }
        if container == nil {
            uploadContainer.wait(block)
        }
        return uploadContainer.tasks
    }

    public func deleteFiles(container: DeleteContainer?, block: ((Error?) -> Void)?) {

        var deleteContainer: DeleteContainer = container ?? DeleteContainer()

        for (_, child) in Mirror(reflecting: self).children.enumerated() {
            guard let key: String = child.label else { break }
            if self.ignore.contains(key) { break }
            let value = child.value

            switch DataType(key: key, value: value) {
            case .file(let key, _, let file):
                deleteContainer.group.enter()
                file.delete({ (error) in
                    defer {
                        deleteContainer.group.leave()
                    }
                    if let error: Error = error {
                        deleteContainer.error = error
                        return
                    }
                })
            case .collection(_, _, let collection):
                collection.deleteFiles(container: container, block: nil)
            default: break
            }
        }

        if container == nil {
            deleteContainer.wait(block)
        }
    }
}

public extension Document {

    public static func get(_ id: String, block: @escaping (Self?, Error?) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            let document: Self = Self(snapshot: snapshot)
            block(document, nil)
        }
    }

    public static func listen(_ id: String, block: @escaping (Self?, Error?) -> Void) -> ListenerRegistration {
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

    public func listen(_ block: @escaping (Self?, Error?) -> Void) -> ListenerRegistration {
        let options: DocumentListenOptions = DocumentListenOptions()
        var isFirst: Bool = true
        return self.reference.addSnapshotListener(options: options) { (snapshot, error) in
            // Do not process at the first time
            if isFirst {
                isFirst = false
                return
            }
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            let document: Self = Self(snapshot: snapshot)
            block(document, nil)
        }
    }

    public func listen(block: @escaping (Self?, Error?) -> Void) -> Disposer<Self> {
        return .init(.value(listen(block)))
    }

    public func ref() -> Reference<Self> {
        return Reference(self)!
    }
}

public extension Document where Self: Object {

    public static var query: DataSource<Self>.Query {
        return DataSource.Query(self.reference)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo), reference: self.reference)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isLessThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan), reference: self.reference)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isLessThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isGreaterThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan), reference: self.reference)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isGreaterThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
    }

    public static func order(by: PartialKeyPath<Self>) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!), reference: self.reference)
    }

    public static func order(by: PartialKeyPath<Self>, descending: Bool) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!, descending: descending), reference: self.reference)
    }

    public static func limit(to: Int) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.limit(to: to), reference: self.reference)
    }

    public static func start(at: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.start(at: at), reference: self.reference)
    }

    public static func start(after: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.start(after: after), reference: self.reference)
    }

    public static func start(atDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.start(atDocument: atDocument), reference: self.reference)
    }

    public static func start(afterDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.start(afterDocument: afterDocument), reference: self.reference)
    }

    public static func end(at: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.end(at: at), reference: self.reference)
    }

    public static func end(atDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.end(atDocument: atDocument), reference: self.reference)
    }

    public static func end(before: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.end(before: before), reference: self.reference)
    }

    public static func end(beforeDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.end(beforeDocument: beforeDocument), reference: self.reference)
    }
}
