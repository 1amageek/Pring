//
//  SubCollection.swift
//  Pring
//
//  Created by 1amageek on 2018/01/15.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

open class SubCollection<T: Document>: AnySubCollection, ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = T

    internal var _dataSource: DataSource<T> = []

    internal var _self: [T] = []

    internal var _insertions: Set<T> = []

    internal var _deletions: Set<T> = []

    /// Contains the Object holding the property.
    public weak var parent: Object?

    public var key: String?

    public var batchID: String?

    /// It is a Path stored in Firebase.
    public var path: String {
        guard let parent: Object = self.parent else {
            fatalError("[Pring.SubCollection] It is necessary to set parent.")
        }
        guard let key: String = self.key else {
            fatalError("[Pring.SubCollection] It is necessary to set key.")
        }
        return "\(parent.path)/\(key)"
    }

    public var reference: CollectionReference {
        return Firestore.firestore().collection(path)
    }

    /// It is an Object whose ID is Key.
    public var references: [String: Any] {
        return _self.values()
    }

    /// You can retrieve whether the parent Object is saved.
    public var isSaved: Bool {
        return self.parent?.isSaved ?? false
    }

    public var count: Int {
        return self._self.count
    }

    /**

    */
    @discardableResult
    public func pack(_ type: BatchType, batch: WriteBatch) -> WriteBatch {
        switch type {
        case .save:
            _self.forEach { (document) in
                batch.setData(document.value , forDocument: document.reference)
                document.pack(type, batch: batch)
            }
        case .update:
            _insertions.subtracting(_deletions).forEach({ (document) in
                document.pack(type, batch: batch)
            })
            _deletions.subtracting(_insertions).forEach({ (document) in
                batch.deleteDocument(document.reference)
            })
        case .delete:
            self.forEach { (document) in
                batch.deleteDocument(document.reference)
            }
        }
        return batch
    }

    public func batch(_ type: BatchType, completion batchID: String) {
        self.forEach { (document) in
            document.batch(type, completion: batchID)
        }
        _deletions = []
        _insertions = []
    }

    /**
     Initialize Relation.
     */
    public init(_ elements: [ArrayLiteralElement]) {
        self._self = elements
    }

    public required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }

    public func setValue(_ value: Any?, forKey key: String) {
        self.key = key
    }

    /// Returns the Object of the specified indexes.
    public func objects(at indexes: IndexSet) -> [Element] {
        return indexes.filter { $0 < self.count }.map { self[$0] }
    }

    // MARK: -

    /// Save the new Object.
    public func insert(_ newMember: Element) {
        newMember.setReference(self.reference.document(newMember.id))
        if !_self.contains(newMember) {
            _self.append(newMember)
        }
        _insertions.insert(newMember)
    }

    public func insert(_ newMembers: [Element]) {
        newMembers.forEach { (newMemeber) in
            insert(newMemeber)
        }
    }

    /// Deletes the Object from the reference destination.
    public func remove(_ member: Element) {
        if let index: Int = _self.index(of: member) {
            _self.remove(at: index)
        }
        let _member: Element = Element(id: member.id, value: [:])
        _member.setReference(self.reference.document(member.id))
        _deletions.insert(_member)
        member.setReference(Element.reference.document(member.id))
    }

    /// Deletes the Document contained in SubCollection from ID.
    public func remove(_ id: String) {
        let document: Element = Element(id: id)
        self.remove(document)
    }

    public func contains(_ id: String, block: @escaping (Bool) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            return block(snapshot?.exists ?? false)
        }
    }

    public func delete(id: String, block: ((Error?) -> Void)? = nil) {
        self.reference.document(id).delete { (error) in
            block?(error)
        }
    }

    public func shouldUploadFiles(_ id: String) -> Bool {
        for (_, document) in self.enumerated() {
            if document.shouldUploadFiles(id) {
                return true
            }
        }
        return false
    }

    public func saveFiles(_ id: String, container: UploadContainer? = nil, block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {
        let uploadContainer: UploadContainer = container ?? UploadContainer()
        self.forEach { document in
            document.saveFiles(id, container: uploadContainer, block: nil)
        }
        return uploadContainer.tasks
    }

    public func deleteFiles(_ id: String, container: DeleteContainer? = nil, block: ((Error?) -> Void)? = nil) {
        let deleteContainer: DeleteContainer = container ?? DeleteContainer()
        self.forEach { document in
            document.deleteFiles(id, container: deleteContainer, block: nil)
        }
    }

    public func get(_ query: DataSource<T>.Query? = nil, block: ((QuerySnapshot?, [T]) -> Void)?) {
        let query: DataSource<T>.Query = query ?? self.query
        self._dataSource = query.dataSource().onCompleted { [weak self] (snapshot, documents) in
            self?._self = documents
            block?(snapshot, documents)
        }.get()
    }

    public func doc(_ id: String) -> T {
        let doc: T = T(id: id, value: [:])
        doc.setReference(self.reference.document(id))
        return doc
    }

    public var description: String {
        if _self.isEmpty {
            return "SubCollection([])"
        }
        return """
            \(_self.description)
        """
    }
}

// MARK: -

public extension SubCollection {

    func get(_ id: String, block: @escaping (Element?, Error?) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            guard let document: Element = ArrayLiteralElement(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    func listen(_ id: String, block: @escaping (Element?, Error?) -> Void) -> ListenerRegistration {
        return self.reference.document(id).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot else {
                block(nil, error)
                return
            }
            guard let document: Element = ArrayLiteralElement(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    func listen(_ id: String, block: @escaping (Element?, Error?) -> Void) -> Disposer<Element> {
        return .init(.value(listen(id, block: block)))
    }
}

extension SubCollection: Collection {

    public var startIndex: Int {
        return _self.startIndex
    }

    public var endIndex: Int {
        return _self.endIndex
    }

    public var first: T? {
        return _self.first
    }

    public var last: T? {
        return _self.last
    }

    public subscript(i: Int) -> T {
        return _self[i]
    }

    public func index(of element: T) -> Int? {
        return _self.index(of: element)
    }

    public func index(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try _self.firstIndex(where: predicate)
    }

    public func index(after i: Int) -> Int {
        return _self.index(after: i)
    }

    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return _self.index(i, offsetBy: n)
    }

    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return _self.index(i, offsetBy: n, limitedBy: limit)
    }
}

fileprivate extension Collection where Iterator.Element: Document {
    func values() -> [String: Any] {
        return reduce(into: [:]) { $0[$1.id] = $1.value }
    }
}

