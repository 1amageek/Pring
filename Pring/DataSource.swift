//
//  DataSource.swift
//  Pring
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

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

    /// Number to be referenced at one time
    public var limit: UInt = 30     // Default Limit 30

    /// Fetch timeout
    public var timeout: Int = 10    // Default Timeout 10s

    /// Predicate
    public var predicate: NSPredicate?

    /// Sort order
    public var sortDescirptors: [NSSortDescriptor] = [NSSortDescriptor(key: "id", ascending: false)]

    public init() { }
}

/// DataSource class.
/// Observe at a Firebase DataSource location.
public final class DataSource<T: Object>: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = T

    public typealias Element = ArrayLiteralElement

    /// Objects held in the client
    public var documents: [Element] = []

    /// Count
    public var count: Int { return documents.count }

    /// Reference of element
    private(set) var reference: CollectionReference

    /// Options
    private(set) var options: Options

    private let fetchQueue: DispatchQueue = DispatchQueue(label: "Pring.datasource.fetch.queue")

    private var listenr: FIRListenerRegistration?

    private var nextReference: Query?

    /// Holds the Key previously sent to Firebase.
    private var previousLastKey: String?

    /// Block called when there is a change in DataSource
    private var changedBlock: ((CollectionChange) -> Void)?

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
    public init(reference: CollectionReference, options: Options = Options(), block: ((CollectionChange) -> Void)?) {
        self.reference = reference
        self.options = options
        self.changedBlock = block
        self.on(block)
    }

    /// Initializing the DataSource
    public required convenience init(arrayLiteral documents: Element...) {
        self.init(documents)
    }

    /// Initializing the DataSource
    public init(_ documents: [Element]) {
        self.reference = Element.reference
        self.options = Options()
        self.documents = documents
    }

    /// Set the Block to receive the change of the DataSource.
    @discardableResult
    public func on(_ block: ((CollectionChange) -> Void)?) -> Self {
        self.changedBlock = block
        return self
    }

    /// Monitor changes in the DataSource.
    public func observe() {
        guard let block: (CollectionChange) -> Void = self.changedBlock else {
            fatalError("[Pring.DataSource] *** error: You need to define Changeblock to start observe.")
        }
        var isFirst: Bool = true
        let options: QueryListenOptions = QueryListenOptions()
        self.listenr = self.reference.addSnapshotListener(options: options, listener: { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            guard let snapshot: QuerySnapshot = snapshot else {
                block(CollectionChange(change: nil, error: error))
                return
            }

            self.operate(with: snapshot, error: error)
            if isFirst {
                guard let lastSnapshot = snapshot.documents.last else {
                    // The collection is empty.
                    return
                }
                self.nextReference = self.reference.start(atDocument: lastSnapshot)
                isFirst = false
            }
        })
    }

    private func operate(with snapshot: QuerySnapshot?, error: Error?) {
        guard let block: (CollectionChange) -> Void = self.changedBlock else {
            fatalError("[Pring.DataSource] *** error: You need to define Changeblock to start observe.")
        }
        guard let snapshot: QuerySnapshot = snapshot else {
            block(CollectionChange(change: nil, error: error))
            return
        }
        snapshot.documentChanges.forEach({ (change) in
            let id: String = change.document.documentID
            switch change.type {
            case .added:
                guard !self.documents.flatMap({return $0.id}).contains(id) else {
                    return
                }
                Element.get(id, block: { (document, error) in
                    guard let document: Element = document else { return }
                    self.documents.append(document)
                    self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                    if let i: Int = self.documents.index(of: document) {
                        block(CollectionChange(change: (deletions: [], insertions: [i], modifications: []), error: nil))
                    }
                })
            case .modified:
                guard self.documents.flatMap({return $0.id}).contains(id) else {
                    return
                }
                Element.get(id, block: { (document, error) in
                    guard let document: Element = document else { return }
                    if let i: Int = self.documents.index(of: id) {
                        self.documents.remove(at: i)
                    }
                    self.documents.append(document)
                    self.documents = self.filtered().sort(sortDescriptors: self.options.sortDescirptors)
                    if let i: Int = self.documents.index(of: document) {
                        block(CollectionChange(change: (deletions: [], insertions: [], modifications: [i]), error: nil))
                    }
                })
            case .removed:
                guard self.documents.flatMap({return $0.id}).contains(id) else {
                    return
                }
                if let i: Int = self.documents.index(of: id) {
                    self.documents.remove(at: i)
                    block(CollectionChange(change: (deletions: [i], insertions: [], modifications: []), error: nil))
                }
            }
        })
    }

    /**
     Load the previous data from the server.
     - parameter lastKey: It gets the data after the Key
     - parameter limit: It the limit of from after the lastKey.
     - parameter block: block The block that should be called. Change if successful will be returned. An error will return if it fails.
     */
    public func next(_ limit: Int = 30) {
        self.nextReference?.limit(to: limit).getDocuments(completion: { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            self.operate(with: snapshot, error: error)
            guard let lastSnapshot = snapshot?.documents.last else {
                // The collection is empty.
                return
            }
            self.nextReference = self.reference.start(atDocument: lastSnapshot)
        })
    }

    /**
     Remove object
     - parameter index: Order of the data source
     - parameter parent: Also deletes the data of the reference case of `true`.
     - parameter block: block The block that should be called. If there is an error it returns an error.
     */
    public func removeObject(at index: Int, block: @escaping (String, Error?) -> Void) {
        let id: String = self.documents[index].id
        self.reference.document(id).delete { (error) in
            block(id, error)
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
        if self.documents.isEmpty { return nil}
        return try self.documents.index(where: predicate)
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
}

extension Array where Element: Document {

    public var keys: [String] {
        return self.flatMap { return $0.id }
    }

    public func index(of key: String) -> Int? {
        return self.keys.index(of: key)
    }
}

