//
//  AnySubCollection.swift
//  Pring
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public protocol AnySubCollection: class, StorageLinkable, Batchable {
    
    var path: String { get }
    
    var reference: CollectionReference { get }
    
    var key: String? { get set }
    
    var parent: Object? { get set }
    
    var references: [AnyHashable: Any] { get }
    
    func setValue(_ value: Any?, forKey key: String)
    
    func setParent(_ object: Object, forKey key: String)
}

public protocol Countable {

    var value: [AnyHashable: Any] { get }
}

public typealias CountableSubCollection = AnySubCollection & Countable

extension AnySubCollection {
    
    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
}

extension AnySubCollection where Self: Collection, Self.Element: Document {

    public func shouldUploadFiles(_ id: String) -> Bool {
        for (_, document) in self.enumerated() {
            if document.shouldUploadFiles(id) {
                return true
            }
        }
        return false
    }
    
    public func saveFiles(container: UploadContainer? = nil, block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {
        let uploadContainer: UploadContainer = container ?? UploadContainer()
        self.forEach { document in
            document.saveFiles(container: uploadContainer, block: nil)
        }
        return uploadContainer.tasks
    }
    
    public func deleteFiles(container: DeleteContainer? = nil, block: ((Error?) -> Void)?) {
        let deleteContainer: DeleteContainer = container ?? DeleteContainer()
        self.forEach { document in
            document.deleteFiles(container: deleteContainer, block: nil)
        }
    }
}

public extension AnySubCollection where Self: Collection, Self.Element: Document {
    
    public var query: DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference)
    }
    
    // MARK:
    
    public func `where`(_ keyPath: PartialKeyPath<Self.Element>, isEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo), reference: self.reference)
    }
    
    public func `where`(_ keyPath: PartialKeyPath<Self.Element>, isLessThan: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan), reference: self.reference)
    }
    
    public func `where`(_ keyPath: PartialKeyPath<Self.Element>, isLessThanOrEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
    }
    
    public func `where`(_ keyPath: PartialKeyPath<Self.Element>, isGreaterThan: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan), reference: self.reference)
    }
    
    public func `where`(_ keyPath: PartialKeyPath<Self.Element>, isGreaterThanOrEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
    }
    
    public func order(by: PartialKeyPath<Self.Element>) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!), reference: self.reference)
    }
    
    public func order(by: PartialKeyPath<Self.Element>, descending: Bool) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!, descending: descending), reference: self.reference)
    }
    
    // MARK:
    
    public func `where`(_ keyPath: String, isEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isEqualTo: isEqualTo), reference: self.reference)
    }
    
    public func `where`(_ keyPath: String, isLessThan: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThan: isLessThan), reference: self.reference)
    }
    
    public func `where`(_ keyPath: String, isLessThanOrEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
    }
    
    public func `where`(_ keyPath: String, isGreaterThan: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThan: isGreaterThan), reference: self.reference)
    }
    
    public func `where`(_ keyPath: String, isGreaterThanOrEqualTo: Any) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
    }
    
    public func order(by: String) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.order(by: by), reference: self.reference)
    }
    
    public func order(by: String, descending: Bool) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.order(by: by, descending: descending), reference: self.reference)
    }
    
    // MARK:
    
    public func limit(to: Int) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.limit(to: to), reference: self.reference)
    }
    
    public func start(at: [Any]) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.start(at: at), reference: self.reference)
    }
    
    public func start(after: [Any]) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.start(after: after), reference: self.reference)
    }
    
    public func start(atDocument: DocumentSnapshot) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.start(atDocument: atDocument), reference: self.reference)
    }
    
    public func start(afterDocument: DocumentSnapshot) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.start(afterDocument: afterDocument), reference: self.reference)
    }
    
    public func end(at: [Any]) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.end(at: at), reference: self.reference)
    }
    
    public func end(atDocument: DocumentSnapshot) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.end(atDocument: atDocument), reference: self.reference)
    }
    
    public func end(before: [Any]) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.end(before: before), reference: self.reference)
    }
    
    public func end(beforeDocument: DocumentSnapshot) -> DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference.end(beforeDocument: beforeDocument), reference: self.reference)
    }
}

public extension ReferenceCollection {

    public var query: DataSource<Element>.Query {
        return DataSource.Query(self.reference, hasRealities: false)
    }

    // MARK:

    public func `where`(_ keyPath: PartialKeyPath<Element>, isEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThan: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThanOrEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThan: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThanOrEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference, hasRealities: false)
    }

    public func order(by: PartialKeyPath<Element>) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!), reference: self.reference, hasRealities: false)
    }

    public func order(by: PartialKeyPath<Element>, descending: Bool) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.order(by: by._kvcKeyPathString!, descending: descending), reference: self.reference, hasRealities: false)
    }

    // MARK:

    public func `where`(_ keyPath: String, isEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isEqualTo: isEqualTo), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: String, isLessThan: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThan: isLessThan), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: String, isLessThanOrEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: String, isGreaterThan: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThan: isGreaterThan), reference: self.reference, hasRealities: false)
    }

    public func `where`(_ keyPath: String, isGreaterThanOrEqualTo: Any) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.whereField(keyPath, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference, hasRealities: false)
    }

    public func order(by: String) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.order(by: by), reference: self.reference, hasRealities: false)
    }

    public func order(by: String, descending: Bool) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.order(by: by, descending: descending), reference: self.reference, hasRealities: false)
    }

    // MARK:

    public func limit(to: Int) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.limit(to: to), reference: self.reference, hasRealities: false)
    }

    public func start(at: [Any]) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.start(at: at), reference: self.reference, hasRealities: false)
    }

    public func start(after: [Any]) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.start(after: after), reference: self.reference, hasRealities: false)
    }

    public func start(atDocument: DocumentSnapshot) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.start(atDocument: atDocument), reference: self.reference, hasRealities: false)
    }

    public func start(afterDocument: DocumentSnapshot) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.start(afterDocument: afterDocument), reference: self.reference, hasRealities: false)
    }

    public func end(at: [Any]) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.end(at: at), reference: self.reference, hasRealities: false)
    }

    public func end(atDocument: DocumentSnapshot) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.end(atDocument: atDocument), reference: self.reference, hasRealities: false)
    }

    public func end(before: [Any]) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.end(before: before), reference: self.reference, hasRealities: false)
    }

    public func end(beforeDocument: DocumentSnapshot) -> DataSource<Element>.Query {
        return DataSource.Query(self.reference.end(beforeDocument: beforeDocument), reference: self.reference, hasRealities: false)
    }
}

