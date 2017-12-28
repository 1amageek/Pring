//
//  Object.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

open class Object: NSObject, Document {

    open class var modelVersion: Int {
        return 1
    }

    open class var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    open class var path: String {
        return "version/\(self.modelVersion)/\(self.modelName)"
    }

    open class var reference: CollectionReference {
        return Firestore.firestore().collection(self.path)
    }

    open class var storageRef: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public private(set) var reference: DocumentReference

    public var path: String {
        return self.reference.path
    }

    /// It is Qeueu of File upload.
    public let uploadQueue: DispatchQueue = DispatchQueue(label: "Pring.upload.queue")

    @objc public var id: String

    @objc public var createdAt: Date {
        didSet {
            _createdAt = createdAt
        }
    }

    @objc public var updatedAt: Date {
        didSet {
            _updatedAt = updatedAt
        }
    }

    @objc private var _createdAt: Date

    @objc private var _updatedAt: Date

    public private(set) var isListening: Bool = false

    // MARK: - Initialize

    private func _init() {
        let mirror: Mirror = Mirror(reflecting: self)
        mirror.children.forEach { (child) in
            DataType.verify(value: child.value)
            switch DataType(key: child.label!, value: child.value) {
            case .file          (let key, _, let file):         file.setParent(self, forKey: key)
            case .collection    (let key, _, let collection):   collection.setParent(self, forKey: key)
            case .reference     (let key, _, let reference):    reference.setParent(self, forKey: key)
            default: break
            }
        }
    }

    /// Initialize Object
    public override init() {
        self.createdAt = Date()
        self.updatedAt = Date()
        self._createdAt = Date()
        self._updatedAt = Date()
        self.reference = type(of: self).reference.document()
        self.id = self.reference.documentID
        super.init()
        self._init()
    }

    /// Initialize the object with the specified ID.
    public convenience required init(id: String) {
        self.init()
        self.id = id
        self.reference = type(of: self).reference.document(id)
    }

    /// Initialize Object from snapshot.
    public convenience required init(snapshot: DocumentSnapshot) {
        self.init()
        _setSnapshot(snapshot)
    }

    public convenience required init(id: String, value: [AnyHashable: Any]) {
        self.init()

        self.id = id

        let data: [String: Any] = value as! [String: Any]

        self.createdAt = data[(\Object.createdAt)._kvcKeyPathString!] as? Date ?? _createdAt
        self.updatedAt = data[(\Object.updatedAt)._kvcKeyPathString!] as? Date ?? _updatedAt

        Mirror(reflecting: self).children.forEach { (key, value) in
            if let key: String = key {
                if !self.ignore.contains(key) {
                    if self.decode(key, value: data[key]) {
                        self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                        return
                    }
                    switch DataType(key: key, value: value, data: data) {
                    case .array         (let key, _, let value):                self.setValue(value, forKey: key)
                    case .set           (let key, _, let value):                self.setValue(value, forKey: key)
                    case .bool          (let key, _, let value):                self.setValue(value, forKey: key)
                    case .binary        (let key, _, let value):                self.setValue(value, forKey: key)
                    case .file          (let key, _, let value):                self.setValue(value, forKey: key); value.setParent(self, forKey: key)
                    case .files         (let key, _, let value):                self.setValue(value, forKey: key); value.forEach { $0.setParent(self, forKey: key) }
                    case .url           (let key, _, let value):                self.setValue(value, forKey: key)
                    case .int           (let key, _, let value):                self.setValue(value, forKey: key)
                    case .float         (let key, _, let value):                self.setValue(value, forKey: key)
                    case .date          (let key, _, let value):                self.setValue(value, forKey: key)
                    case .geoPoint      (let key, _, let value):                self.setValue(value, forKey: key)
                    case .dictionary    (let key, _, let value):                self.setValue(value, forKey: key)
                    case .collection    (let key, let value, let collection):   collection.setValue(value, forKey: key)
                    case .reference     (let key, _, let reference):            reference.setParent(self, forKey: key)
                    case .document      (_, _, _):                              break
                    case .string        (let key, _, let value):                self.setValue(value, forKey: key)
                    case .null: break
                    }
                    self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                }
            }
        }
        self.isListening = true
    }

    func _setSnapshot(_ snapshot: DocumentSnapshot) {
        self.snapshot = snapshot
    }

    internal func set(_ reference: DocumentReference) {
        self.reference = reference
    }

    public var snapshot: DocumentSnapshot? {
        didSet {
            if let snapshot: DocumentSnapshot = snapshot {

                self.reference = snapshot.reference
                self.id = snapshot.documentID

                let data: [String: Any] = snapshot.data()

                self.createdAt = data[(\Object.createdAt)._kvcKeyPathString!] as? Date ?? _createdAt
                self.updatedAt = data[(\Object.updatedAt)._kvcKeyPathString!] as? Date ?? _updatedAt

                Mirror(reflecting: self).children.forEach { (key, value) in
                    if let key: String = key {
                        if !self.ignore.contains(key) {
                            if self.decode(key, value: data[key]) {
                                self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                                return
                            }
                            switch DataType(key: key, value: value, data: data) {
                            case .array         (let key, _, let value):                self.setValue(value, forKey: key)
                            case .set           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .bool          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .binary        (let key, _, let value):                self.setValue(value, forKey: key)
                            case .file          (let key, _, let value):                self.setValue(value, forKey: key); value.setParent(self, forKey: key)
                            case .files         (let key, _, let value):                self.setValue(value, forKey: key); value.forEach { $0.setParent(self, forKey: key) }
                            case .url           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .int           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .float         (let key, _, let value):                self.setValue(value, forKey: key)
                            case .date          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .geoPoint      (let key, _, let value):                self.setValue(value, forKey: key)
                            case .dictionary    (let key, _, let value):                self.setValue(value, forKey: key)
                            case .collection    (let key, let value, let collection):   collection.setValue(value, forKey: key)
                            case .reference     (let key, _, let reference):            reference.setParent(self, forKey: key)
                            case .document      (_, _, _):                              break
                            case .string        (let key, _, let value):                self.setValue(value, forKey: key)
                            case .null: break
                            }
                            self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                        }
                    }
                }
                self.isListening = true
            }
        }
    }

    // MARK: -

    /// Model -> Firebase
    open func encode(_ key: String, value: Any?) -> Any? {
        return nil
    }

    /// Snapshot -> Model
    ///
    /// - Parameters:
    ///   - key: Property name
    ///   - value: Data saved in Firebase Snapshot
    /// - Returns: For properties to be decoded, set to true.
    open func decode(_ key: String, value: Any?) -> Bool {
        return false
    }

    /// If propery is set with String, its property will not be written to Firebase.
    open var ignore: [String] {
        return []
    }

    // MARK: -

    /// Object raw value
    public var rawValue: [AnyHashable: Any] {
        let mirror = Mirror(reflecting: self)
        var document: [AnyHashable: Any] = [:]
        mirror.children.forEach { (key, value) in
            if let key: String = key {
                if !self.ignore.contains(key) {
                    if let rawValue: Any = self.encode(key, value: value) {
                        document[key] = rawValue
                        return
                    }

                    let value: Any? = DataType.unwrap(value)

                    switch DataType(key: key, value: value) {
                    case .array         (let key, let rawValue, _):   document[key] = rawValue
                    case .set           (let key, let rawValue, _):   document[key] = rawValue
                    case .bool          (let key, let rawValue, _):   document[key] = rawValue
                    case .binary        (let key, let rawValue, _):   document[key] = rawValue
                    case .file          (let key, let rawValue, _):   document[key] = rawValue
                    case .files         (let key, let rawValue, _):   document[key] = rawValue
                    case .url           (let key, let rawValue, _):   document[key] = rawValue
                    case .int           (let key, let rawValue, _):   document[key] = rawValue
                    case .float         (let key, let rawValue, _):   document[key] = rawValue
                    case .date          (let key, let rawValue, _):   document[key] = rawValue
                    case .geoPoint      (let key, let rawValue, _):   document[key] = rawValue
                    case .dictionary    (let key, let rawValue, _):   document[key] = rawValue
                    case .collection    (let key, let rawValue, _):   document[key] = rawValue
                    case .reference     (let key, let rawValue, _):   document[key] = rawValue
                    case .string        (let key, let rawValue, _):   document[key] = rawValue
                    case .document      (let key, let rawValue, _):   document[key] = rawValue
                    case .null: break
                    }
                }
            }
        }
        return document
    }

    /// Object value
    public var value: [AnyHashable: Any] {
        var value: [AnyHashable: Any] = self.rawValue
        if isListening {
            value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
        } else {
            value[(\Object.createdAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
            value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
        }
        return value
    }

    // MARK: - KVO

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard let keyPath: String = keyPath else {
            super.observeValue(forKeyPath: nil, of: object, change: change, context: context)
            return
        }

        guard let object: NSObject = object as? NSObject else {
            super.observeValue(forKeyPath: keyPath, of: nil, change: change, context: context)
            return
        }

        let keys: [String] = Mirror(reflecting: self).children.flatMap({ return $0.label })
        if keys.contains(keyPath) {

            if let value: Any = object.value(forKey: keyPath) as Any? {
                switch DataType(key: keyPath, value: value) {
                case .array         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .set           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .bool          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .binary        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .file          (let key, _, _):
                    if let change: [NSKeyValueChangeKey: Any] = change as [NSKeyValueChangeKey: Any]? {
                        guard let currentFile: File = change[.newKey] as? File else {
                            fatalError("[Pring.Document] *** error: The file has been set to nil. If you mean delete, please use File.delete.")
                        }
                        if let previousFile: File = change[.oldKey] as? File {
                            previousFile.parent = self
                            previousFile.key = key
                            currentFile.garbage = previousFile.ref
                        }
                        currentFile.parent = self
                        currentFile.key = key
                    }
                case .files         (let key, _, _):
                    if let change: [NSKeyValueChangeKey: Any] = change as [NSKeyValueChangeKey: Any]? {
                        guard let newFiles: [File] = change[.newKey] as? [File] else {
                            fatalError("[Pring.Document] *** error: The files has been set to nil. If you mean delete, please use File.delete.")
                        }
                        guard let oldFiles: [File] = change[.oldKey] as? [File] else {
                            fatalError("[Pring.Document] *** error: The files has been set to nil. If you mean delete, please use File.delete.")
                        }
                        let new: Set<File> = Set(newFiles)
                        let old: Set<File> = Set(oldFiles)
                        new.subtracting(old).forEach { file in
                            file.setParent(self, forKey: key)
                        }
                        old.subtracting(new).forEach { file in
                            file.setParent(self, forKey: key)
                        }
                    }
                case .url           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .int           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .float         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .date          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .geoPoint      (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .dictionary    (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .collection    (_, _, _):   break
                case .reference     (_, _, _):   break
                case .document      (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .string        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .null: break
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    internal var updateValue: [AnyHashable: Any] = [:]

//    internal var garbages: [File] = []

    /**
     Update the data on Firebase.
     When this function is called, updatedAt of Object is updated at the same time.

     - parameter key: Document field name
     - parameter value: Save to value. If you enter nil
     */
    internal func update(key: String, value: Any) {
        updateValue[key] = value
    }

    @discardableResult
    public func pack(_ type: BatchType, batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        switch type {
        case .save:
            batch.setData(self.value as! [String : Any], forDocument: self.reference)
            self.each({ (key, value) in
                if let value = value {
                    switch DataType(key: key, value: value) {
                    case .collection    (_, _, let collection):     collection.pack(.save, batch: batch)
                    case .reference     (_, _, let reference):
                        if reference is Batchable {
                            (reference as! Batchable).pack(.save, batch: batch)
                        }
                    default: break
                    }
                }
            })
        case .update:
            updateValue[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
            batch.updateData(updateValue, forDocument: self.reference)
            self.each({ (key, value) in
                if let value = value {
                    switch DataType(key: key, value: value) {
                    case .reference     (_, _, let reference):
                        if reference is Batchable {
                            (reference as! Batchable).pack(.update, batch: batch)
                        }
                    default: break
                    }
                }
            })
        case .delete:
            batch.deleteDocument(self.reference)
        }
        return batch
    }

    // MARK: SAVE

    /**
     Save the new Object to Firebase. Save will fail in the off-line.
     - parameter completion: If successful reference will return. An error will return if it fails.
     */
    @discardableResult
    public func save(_ block: ((DocumentReference?, Error?) -> Void)? = nil) -> [String: StorageUploadTask] {
        return self.save(nil, block: block)
    }

    @discardableResult
    public func save(_ batch: WriteBatch? = nil, block: ((DocumentReference?, Error?) -> Void)? = nil) -> [String: StorageUploadTask] {
        if isListening {
            fatalError("[Pring.Document] *** error: \(type(of: self)) has already been saved.")
        }
        let ref: DocumentReference = self.reference
        if self.hasFiles {
            return self.saveFiles(container: nil) { (error) in
                if let error = error {
                    block?(ref, error)
                    return
                }
                self._save(batch, block: block)
            }
        } else {
            _save(batch, block: block)
            return [:]
        }
    }

    private func _save(_ batch: WriteBatch? = nil, block: ((DocumentReference?, Error?) -> Void)?) {
        self.pack(.save, batch: batch).commit { (error) in
            if let error: Error = error {
                block?(nil, error)
                return
            }
            self.reference.getDocument(completion: { (snapshot, error) in
                self.snapshot = snapshot
                block?(snapshot?.reference, error)
            })
        }
    }

    // MARK: UPDATE
//    public func update(_ block: ((Error?) -> Void)? = nil) {
//
//        self.update(nil, block: block)
//    }

    @discardableResult
    public func update(_ batch: WriteBatch? = nil, block: ((Error?) -> Void)? = nil) -> [String: StorageUploadTask] {
        if !isListening {
            fatalError("[Pring.Document] *** error: \(type(of: self)) has not been saved yet.")
        }
        if self.hasFiles {
            return self.saveFiles(container: nil) { (error) in
                if let error = error {
                    block?(error)
                    return
                }
                self._update(batch, block: block)
            }
        } else {
            _update(batch, block: block)
            return [:]
        }
    }

    private func _update(_ batch: WriteBatch? = nil, block: ((Error?) -> Void)?) {
        self.pack(.update, batch: batch).commit { (error) in
            if let error: Error = error {
                block?(error)
                return
            }
            self.updateValue = [:]
            block?(nil)
        }
    }

    // MARK: DELETE

    public func delete(_ block: ((Error?) -> Void)? = nil) {
        self.delete(nil, block: block)
    }

    public func delete(_ batch: WriteBatch? = nil, block: ((Error?) -> Void)? = nil) {
        self.pack(.delete, batch: batch).commit { (error) in
            if let error = error {
                block?(error)
                return
            }
            self.updateValue = [:]
            self.deleteFiles(container: nil, block: block)
        }
    }

    // MARK: -

    override open var description: String {
        let base: String =
            "  id: \(self.id)\n" +
            "  createdAt: \(self.createdAt)\n" +
            "  updatedAt: \(self.updatedAt)\n"

        let values: String = Mirror(reflecting: self).children.reduce(base) { (result, children) -> String in
            guard let label: String = children.0 else {
                return result
            }
            return result + "  \(label): \(String(describing: children.1))\n"
        }
        let _self: String = String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!
        return "\(_self) {\n\(values)}"
    }

    public subscript(key: String) -> Any? {
        get {
            return self.value(forKey: key)
        }
        set(newValue) {
            self.setValue(newValue, forKey: key)
        }
    }

    private func each(_ block: (String, Any?) -> Void) {
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { (key, value) in
            if let key: String = key {
                let value: Any? = DataType.unwrap(value)
                block(key, value)
            }
        }
    }

    // MARK: Deinit

    deinit {
        if self.isListening {
            Mirror(reflecting: self).children.forEach { (key, value) in
                if let key: String = key {
                    if !self.ignore.contains(key) {
                        self.removeObserver(self, forKeyPath: key)
                    }
                }
            }
        }
    }
}

extension Object {
    open override var hashValue: Int {
        return self.id.hash
    }
    public static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.id == rhs.id && type(of: lhs).modelVersion == type(of: rhs).modelVersion
    }
}

public struct DocumentError: Error {
    enum ErrorKind {
        case invalidId
        case invalidFile
        case timeout
        case offlineTransaction
        case lostCompletion
    }
    let kind: ErrorKind
    let description: String
}

extension Sequence where Iterator.Element: Object {
    /// Return an `Array` containing the sorted elements of `source`
    /// using criteria stored in a NSSortDescriptors array.

    public func sort(sortDescriptors theSortDescs: [NSSortDescriptor]) -> [Self.Iterator.Element] {
        return sorted {
            for sortDesc in theSortDescs {
                switch sortDesc.compare($0, to: $1) {
                case .orderedAscending: return true
                case .orderedDescending: return false
                case .orderedSame: continue
                }
            }
            return false
        }
    }
}
