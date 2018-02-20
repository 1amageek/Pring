//
//  DataSource.swift
//  Pring
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public struct DataSourceError: Error {
    public enum ErrorKind {
        case invalidReference
        case empty
        case timeout
    }

    public let kind: ErrorKind

    public var description: String {
        switch self.kind {
        case .invalidReference: return "The value you are trying to reference is invalid."
        case .empty: return "There was no value."
        case .timeout: return "DataSource fetch timed out."
        }
    }
}


public typealias Change = (deletions: [Int], insertions: [Int], modifications: [Int])

public enum CollectionChange {

    case initial

    case update(Change)

    case error(Error)

    init(change: Change?, error: Error?) {
        if let error: Error = error {
            self = .error(error)
            return
        }
        if let change: Change = change {
            self = .update(change)
            return
        }
        self = .initial
    }
}

/**
 Options class
 */
public final class Options {

    /// Fetch timeout
    public var timeout: Int = 10    // Default Timeout 10s

    public var includeQueryMetadataChanges: Bool = false

    public var includeDocumentMetadataChanges: Bool = false

    /// Predicate
    public var predicate: NSPredicate?

    /// Sort order
    public var sortDescirptors: [NSSortDescriptor] = []

    public init() { }
}

/// DataSource class.
/// Observe at a Firebase DataSource location.
public final class DataSource<T: Document>: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = T

    public typealias Element = ArrayLiteralElement

    public typealias ChangeBlock = (QuerySnapshot?, CollectionChange) -> Void

    public typealias ParseBlock = (QuerySnapshot?, Element, @escaping ((Element) -> Void)) -> Void

    public typealias CompletedBlock = (QuerySnapshot?, [Element]) -> Void

    public typealias ErrorBlock = (QuerySnapshot?, DataSourceError) -> Void

    /// Objects held in the client
    public var documents: [Element] = []

    /// Count
    public var count: Int { return documents.count }

    /// Reference of element
    private(set) var query: Query

    /// Options
    private(set) var options: Options

    private let fetchQueue: DispatchQueue = DispatchQueue(label: "Pring.datasource.fetch.queue")

    private var listenr: ListenerRegistration?

    /// Holds the Key previously sent to Firebase.
    private var previousLastKey: String?

    /// Block called when there is a change in DataSource
    private var changedBlock: ChangeBlock?

    private var parseBlock: ParseBlock?

    private var completedBlock: CompletedBlock?

    private var errorBlock: ErrorBlock?

    /// Applies the NSPredicate specified by option.
    private func filtered() -> [Element] {
        if let predicate: NSPredicate = self.options.predicate {
            return (self.documents as NSArray).filtered(using: predicate) as! [Element]
        }
        return self.documents
    }

    /**
     DataSource retrieves data from the referenced data. Change the acquisition of data by setting Options.
     If there is a change in the value, it will receive and notify you of the change.

     Handler blocks are called on the same thread that they were added on, and may only be added on threads which are
     currently within a run loop. Unless you are specifically creating and running a run loop on a background thread,
     this will normally only be the main thread.

     - parameter reference: Set DatabaseDeference
     - parameter options: DataSource Options
     - parameter block: A block which is called to process Firebase change evnet.
     */
    public init(reference: Query, options: Options = Options(), block: ChangeBlock? = nil) {
        self.query = reference
        self.options = options
        self.changedBlock = block
    }

    /// Initializing the DataSource
    public required convenience init(arrayLiteral documents: Element...) {
        self.init(documents)
    }

    /// Initializing the DataSource
    public init(_ documents: [Element]) {
        self.query = Element.query
        self.options = Options()
        self.documents = documents
    }

    /// Set the Block to receive the change of the DataSource.
    @discardableResult
    public func on(_ block: ChangeBlock?) -> Self {
        self.changedBlock = block
        return self
    }

    @discardableResult
    public func on(parse block: ParseBlock?) -> Self {
        self.parseBlock = block
        return self
    }

    @discardableResult
    public func onCompleted(_ block: CompletedBlock?) -> Self {
        self.completedBlock = block
        return self
    }

    @discardableResult
    public func onError(_ block: ErrorBlock?) -> Self {
        self.errorBlock = block
        return self
    }

    /// Monitor changes in the DataSource.
    @discardableResult
    public func listen() -> Self {
        let block: ChangeBlock? = self.changedBlock
        var isFirst: Bool = true
        let options: QueryListenOptions = QueryListenOptions()
        options.includeDocumentMetadataChanges(self.options.includeDocumentMetadataChanges)
        options.includeQueryMetadataChanges(self.options.includeQueryMetadataChanges)
        self.listenr = self.query.listen(options: options, listener: { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            guard let snapshot: QuerySnapshot = snapshot else {
                block?(nil, CollectionChange(change: nil, error: error))
                return
            }

            if isFirst {
                guard let lastSnapshot = snapshot.documents.last else {
                    // The collection is empty.
                    return
                }
                self.query = self.query.start(atDocument: lastSnapshot)
                isFirst = false
            }
            self._operate(with: snapshot, error: error)
        })
        return self
    }

    private func _operate(with snapshot: QuerySnapshot?, error: Error?) {
        let changeBlock: ChangeBlock? = self.changedBlock
        let parseBlock: ParseBlock? = self.parseBlock
        let completedBlock: CompletedBlock? = self.completedBlock
        let errorBlock: ErrorBlock? = self.errorBlock
        guard let snapshot: QuerySnapshot = snapshot else {
            changeBlock?(nil, CollectionChange(change: nil, error: error))
            completedBlock?(nil, [])
            return
        }

        self.fetchQueue.async {
            let group: DispatchGroup = DispatchGroup()
            snapshot.documentChanges.forEach({ (change) in
                let id: String = change.document.documentID
                switch change.type {
                case .added:
                    guard !self.documents.flatMap({return $0.id}).contains(id) else {
                        return
                    }
                    group.enter()
                    self.get(with: change, block: { (document, error) in
                        guard let document: Element = document else {
                            let error: Error = error ?? DataSourceError(kind: .invalidReference)
                            let collectionChange: CollectionChange = CollectionChange.error(error)
                            changeBlock?(snapshot, collectionChange)
                            group.leave()
                            return
                        }
                        if let parseBlock: ParseBlock = parseBlock {
                            parseBlock(snapshot, document, { document in
                                self.documents.append(document)
                                self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                                if let i: Int = self.documents.index(of: document) {
                                    changeBlock?(snapshot, CollectionChange(change: (deletions: [], insertions: [i], modifications: []), error: nil))
                                }
                                group.leave()
                            })
                        } else {
                            self.documents.append(document)
                            self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                            if let i: Int = self.documents.index(of: document) {
                                changeBlock?(snapshot, CollectionChange(change: (deletions: [], insertions: [i], modifications: []), error: nil))
                            }
                            group.leave()
                        }
                    })
                case .modified:
                    guard self.documents.flatMap({return $0.id}).contains(id) else {
                        return
                    }
                    group.enter()
                    self.get(with: change, block: { (document, error) in
                        guard let document: Element = document else {
                            let error: Error = error ?? DataSourceError(kind: .invalidReference)
                            let collectionChange: CollectionChange = CollectionChange.error(error)
                            changeBlock?(snapshot, collectionChange)
                            group.leave()
                            return
                        }
                        if let parseBlock: ParseBlock = parseBlock {
                            parseBlock(snapshot, document, { document in
                                if let i: Int = self.documents.index(of: id) {
                                    self.documents.remove(at: i)
                                    self.documents.insert(document, at: i)
                                }
                                self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                                if let i: Int = self.documents.index(of: document) {
                                    changeBlock?(snapshot, CollectionChange(change: (deletions: [], insertions: [], modifications: [i]), error: nil))
                                }
                                group.leave()
                            })
                        } else {
                            if let i: Int = self.documents.index(of: id) {
                                self.documents.remove(at: i)
                                self.documents.insert(document, at: i)
                            }
                            self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                            if let i: Int = self.documents.index(of: document) {
                                changeBlock?(snapshot, CollectionChange(change: (deletions: [], insertions: [], modifications: [i]), error: nil))
                            }
                            group.leave()
                        }
                    })
                case .removed:
                    guard self.documents.flatMap({return $0.id}).contains(id) else {
                        return
                    }
                    group.enter()
                    if let i: Int = self.documents.index(of: id) {
                        changeBlock?(snapshot, CollectionChange(change: (deletions: [i], insertions: [], modifications: []), error: nil))
                        self.documents.remove(at: i)
                        group.leave()
                    }
                }
            })
            group.notify(queue: DispatchQueue.main, execute: {
                completedBlock?(snapshot, self.documents)
            })
            switch group.wait(timeout: .now() + .seconds(self.options.timeout)) {
            case .success: break
            case .timedOut:
                let error: DataSourceError = DataSourceError(kind: .timeout)
                DispatchQueue.main.async {
                    errorBlock?(snapshot, error)
                }
            }
        }
    }

    private func get(with change: DocumentChange, block: @escaping (Element?, Error?) -> Void) {
        if self.query.hasRealities {
            guard let document: Element = Element(snapshot: change.document) else {
                block(nil, nil)
                return
            }
            DispatchQueue.main.async {
                block(document, nil)
            }
        } else {
            let id: String = change.document.documentID
            Element.get(id, block: { (document, error) in
                if let error = error {
                    block(nil, error)
                    return
                }
                let snapshotOptions: SnapshotOptions = SnapshotOptions.serverTimestampBehavior(.estimate)
                document?.createdAt = change.document.data(with: snapshotOptions)["createdAt"] as! Date
                document?.updatedAt = change.document.data(with: snapshotOptions)["updatedAt"] as! Date
                block(document, nil)
            })
        }
    }

    @discardableResult
    public func get() -> Self {
        self.next()
        return self
    }

    @discardableResult
    public func next() -> Self {
        self.query.get(completion: { (snapshot, error) in
            self._operate(with: snapshot, error: error)
            guard let lastSnapshot = snapshot?.documents.last else {
                // The collection is empty.
                return
            }
            self.query = self.query.start(atDocument: lastSnapshot)
        })
        return self
    }

    /**
     Remove object
     - parameter index: Order of the data source
     - parameter parent: Also deletes the data of the reference case of `true`.
     - parameter block: block The block that should be called. If there is an error it returns an error.
     */
    public func removeDocument(at index: Int, block: ((String, Error?) -> Void)? = nil) {
        let document: Element = self.documents[index]
        let id: String = document.id
        document.delete { (error) in
            block?(id, error)
        }
    }

    /**
     Get an object from a data source and observe object changess
     It is need `removeObserver`
     - parameter index: Orderr of the data source
     - parameter block: block The block that should be called.  It is passed the data as a Tsp.
     - see removeObserver
     */
    public func observeObject(at index: Int, block: @escaping (Element?, Error?) -> Void) -> Disposer<Element> {
        let element: Element = self[index]
        var isFirst: Bool = true
        block(element, nil)
        return Element.listen(element.id, block: { (elemnt, error) in
            if isFirst {
                isFirst = false
                return
            }
            block(element, nil)
        })
    }

    // MARK: - deinit

    deinit {
        self.listenr?.remove()
    }
}

/**
 DataSource conforms to Collection
 */
extension DataSource: Collection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.documents.count
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func index(where predicate: (T) throws -> Bool) rethrows -> Int? {
        if self.documents.isEmpty { return nil }
        return try self.documents.index(where: predicate)
    }

    public func index(of element: T) -> Int? {
        if self.documents.isEmpty { return nil }
        return self.documents.index(of: element.id)
    }

    public var first: Element? {
        if self.documents.isEmpty { return nil }
        return self.documents[startIndex]
    }

    public var last: Element? {
        if self.documents.isEmpty { return nil }
        return self.documents[endIndex - 1]
    }

    public func insert(_ newMember: Element) {
        if !self.documents.contains(newMember) {
            self.documents.append(newMember)
        }
    }

    public func remove(_ member: Element) {
        if let index: Int = self.documents.index(of: member) {
            self.documents.remove(at: index)
        }
    }

    public subscript(index: Int) -> Element {
        return self.documents[index]
    }

    public func forEach(_ body: (T) throws -> Void) rethrows {
        return try self.documents.forEach(body)
    }
}

extension Array where Element: Document {

    public var keys: [String] {
        return self.flatMap { return $0.id }
    }

    public func index(of key: String) -> Int? {
        return self.keys.index(of: key)
    }

    public func index(of document: Element) -> Int? {
        return self.keys.index(of: document.id)
    }

    public func sort(sortDescriptors: [NSSortDescriptor]) -> [Element] {
        return (self as NSArray).sortedArray(using: sortDescriptors) as! [Element]
    }
}
