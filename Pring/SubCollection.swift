//
//  ReferenceCollection.swift
//  Pring
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public protocol SubCollection: class, StorageLinkable, Batchable {

    var path: String { get }

    var reference: CollectionReference { get }

    var key: String? { get set }

    var parent: Object? { get set }

    var value: [AnyHashable: Any] { get }

    var references: [AnyHashable: Any] { get }

    func setValue(_ value: Any?, forKey key: String)

    func setParent(_ object: Object, forKey key: String)
}

extension SubCollection {

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
}

extension SubCollection where Self: Collection, Self.Element: Document {

    public var hasFiles: Bool {
        for (_, document) in self.enumerated() {
            if document.hasFiles {
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

public extension SubCollection where Self: Collection, Self.Element: Document {

    public var query: DataSource<Self.Element>.Query {
        return DataSource.Query(self.reference)
    }

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
