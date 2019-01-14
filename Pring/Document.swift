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

    static var shouldBeReplicated: Bool { get }

    var reference: DocumentReference { get }

    var path: String { get }

    var id: String { get }

    var isSaved: Bool { get }

    var rawValue: [String: Any] { get }

    var value: [String: Any] { get }

    var createdAt: Timestamp { set get }

    var updatedAt: Timestamp { set get }

    var ignore: [String] { get }

    var updateValue: [String: Any] { get }

    init()

    init(id: String)

    init?(snapshot: DocumentSnapshot)

    init(id: String, value: [String: Any])

    // MARK:

    func setReference(_ reference: DocumentReference)

    @discardableResult
    func save(_ block: ((DocumentReference?, Error?) -> Void)?) -> [String: StorageUploadTask]

    @discardableResult
    func update(_ block: ((Error?) -> Void)?)  -> [String: StorageUploadTask]

    func delete(_ block: ((Error?) -> Void)?)
}

public extension Document where Self: Object {

    public func shouldUploadFiles(_ id: String) -> Bool {
        if id == self.batchID {
            return false
        }
        self.batchID = id
        for (_, child) in allChildrenUpToRootObject.enumerated() {
            if let key: String = child.label {
                switch DataType(key: key, value: child.value) {
                case .file(_, _, _): return true
                case .files(_, _, let files):
                    if !files.isEmpty {
                        return true
                    }
                case .collection(_, _, let collection):
                    if collection.shouldUploadFiles(id) {
                        return true
                    }
                case .reference(_, _, let reference):
                    if reference.shouldUploadFiles(id) {
                        return true
                    }
                case .relation(_, _, let relation):
                    if relation.shouldUploadFiles(id) {
                        return true
                    }
                case .document(_, _, let document):
                    if document!.shouldUploadFiles(id) {
                        return true
                    }
                default: break
                }
            }
        }
        return false
    }

    @discardableResult
    public func saveFiles(_ id: String, container: UploadContainer? = nil, block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {

        var uploadContainer: UploadContainer = container ?? UploadContainer()

        if id == self.batchID {
            return uploadContainer.tasks
        }
        self.batchID = id

        for (_, child) in allChildrenUpToRootObject.enumerated() {

            guard let key: String = child.label else { break }
            if self.ignore.contains(key) { break }
            let value = child.value

            switch DataType(key: key, value: value) {
            case .file(let key, _, let file):
                file.parent = self
                file.key = key
                if file.shouldBeSaved {
                    uploadContainer.group.enter()
                    if let task: StorageUploadTask = file.save(key, completion: { (meta, error) in
                        defer {
                            uploadContainer.group.leave()
                        }
                        if let error: Error = error {
                            uploadContainer.error = error
                            return
                        }
                        file.parent?.update(key: key, value: file.value)
                    }) {
                        uploadContainer.tasks[key] = task
                    }
                }
            case .files(_, _, let files):
                if !files.isEmpty {
                    for (index, file) in files.enumerated() {
                        if file.shouldBeSaved {
                            file.parent = self
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
                                file.parent?.update(key: key, value: files.map { return $0.value })
                            }) {
                                let path: String = "\(key).\(index)"
                                uploadContainer.tasks[path] = task
                            }
                        }
                    }
                }
            case .collection(_, _, let collection):
                collection.saveFiles(id, container: uploadContainer, block: nil)
            case .reference(_, _, let reference):
                reference.saveFiles(id, container: uploadContainer, block: nil)
            case .relation(_, _, let relation):
                relation.saveFiles(id, container: uploadContainer, block: nil)
            case .document(_, _, let document):
                document?.saveFiles(id, container: uploadContainer, block: nil)
            default: break
            }
        }
        if container == nil {
            uploadContainer.wait(block)
        }
        return uploadContainer.tasks
    }

    public func deleteFiles(_ id: String, container: DeleteContainer?, block: ((Error?) -> Void)?) {

        var deleteContainer: DeleteContainer = container ?? DeleteContainer()

        if id == self.batchID {
            return
        }
        self.batchID = id

        for (_, child) in allChildrenUpToRootObject.enumerated() {
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
            case .files(let key, _, let files):
                if !files.isEmpty {
                    for (index, file) in files.enumerated() {
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
                    }
                }
            default: break
            }
        }

        if container == nil {
            deleteContainer.wait(block)
        }
    }
    
    var allChildrenUpToRootObject: [Mirror.Child] {
        var mirror = Mirror(reflecting: self)
        var children = Array(mirror.children)
        while true {
            guard let thisMirror = mirror.superclassMirror else{
                break
            }
            if thisMirror.subjectType == Object.self{
                break
            }
            children += thisMirror.children
            mirror = thisMirror
        }
        return children
    }
}

public extension Document {

    public static var query: DataSource<Self>.Query {
        return DataSource.Query(self.reference)
    }

    public static func get(_ id: String, block: @escaping (Self?, Error?) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            guard let document: Self = Self(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    public static func listen(_ id: String, block: @escaping (Self?, Error?) -> Void) -> ListenerRegistration {

        return self.reference.document(id).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot else {
                block(nil, error)
                return
            }
            guard let document: Self = Self(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    public static func listen(_ id: String, block: @escaping (Self?, Error?) -> Void) -> Disposer<Self> {
        return .init(.value(listen(id, block: block)))
    }

    public func listen(_ block: @escaping (Self?, Error?) -> Void) -> ListenerRegistration {
        return self.reference.addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            guard let document: Self = Self(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    public func listen(block: @escaping (Self?, Error?) -> Void) -> Disposer<Self> {
        return .init(.value(listen(block)))
    }
}

extension DocumentReference {
    public func get<T: Document>(_ document: T, block: @escaping (T?, Error?) -> Void) {
        self.getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            guard let document: T = T(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }
}

public extension Document where Self: Object {

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isEqualTo: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, isEqualTo: isEqualTo)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isLessThan: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, isLessThan: isLessThan)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isLessThanOrEqualTo: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, isLessThanOrEqualTo: isLessThanOrEqualTo)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isGreaterThan: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, isGreaterThan: isGreaterThan)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, isGreaterThanOrEqualTo: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo)
    }

    public static func `where`(_ keyPath: PartialKeyPath<Self>, arrayContains: Any) -> DataSource<Self>.Query {
        guard let key: String = keyPath._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.where(key, arrayContains: arrayContains)
    }

    public static func order(by: PartialKeyPath<Self>) -> DataSource<Self>.Query {
        guard let key: String = by._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.order(by: key)
    }

    public static func order(by: PartialKeyPath<Self>, descending: Bool) -> DataSource<Self>.Query {
        guard let key: String = by._kvcKeyPathString else {
            fatalError("[Pring.Document] 'keyPath' is not used except for OjbC.")
        }
        return self.order(by: key, descending: descending)
    }

    // MARK:

    public static func `where`(_ keyPath: String, isEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isEqualTo: isEqualTo), reference: self.reference)
    }

    public static func `where`(_ keyPath: String, isLessThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThan: isLessThan), reference: self.reference)
    }

    public static func `where`(_ keyPath: String, isLessThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
    }

    public static func `where`(_ keyPath: String, isGreaterThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThan: isGreaterThan), reference: self.reference)
    }

    public static func `where`(_ keyPath: String, isGreaterThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
    }

    public static func `where`(_ keyPath: String, arrayContains: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, arrayContains: arrayContains), reference: self.reference)
    }

    public static func order(by: String) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.order(by: by), reference: self.reference)
    }

    public static func order(by: String, descending: Bool) -> DataSource<Self>.Query {
        return DataSource.Query(self.reference.order(by: by, descending: descending), reference: self.reference)
    }

    // MARK: -

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
