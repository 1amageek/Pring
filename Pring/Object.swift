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

open class Object: NSObject, Document, HasParent {
    public var parent: Object?
    
    public var key: String?
    
    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
    

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
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db.collection(self.path)
    }

    open class var storageRef: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    /// If you have a relationship in ReferenceCollection, the value is duplicated.
    open class var shouldBeReplicated: Bool {
        return false
    }

    public private(set) var reference: DocumentReference

    open var storageRef: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public var path: String {
        return self.reference.path
    }

    /// It is Qeueu of File upload.
    public let uploadQueue: DispatchQueue = DispatchQueue(label: "Pring.upload.queue")

    @objc public var id: String

    @objc public var createdAt: Timestamp {
        didSet {
            _createdAt = createdAt
        }
    }

    @objc public var updatedAt: Timestamp {
        didSet {
            _updatedAt = updatedAt
        }
    }

    private var _createdAt: Timestamp

    private var _updatedAt: Timestamp

    public var batchID: String?

    private var _hash: Int?

    /// isObserving is a flag that indicates that Document is concerned with my Field.
    internal private(set) var isObserving: Bool = false

    private func _observe() {
        if isObserving {
            return
        }
        allChildrenUpToRootObject.forEach { (key, value) in
            if let key: String = key {
                if !self.ignore.contains(key) {
                    switch DataType(key: key, value: value) {
                    case .collection, .reference, .relation: break
                    default:
                        self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                    }
                }
            }
        }
        self.isObserving = true
    }

    /// isSaved is a flag that indicates that this Document has already been saved.
    public private(set) var isSaved: Bool = false

    // MARK: - Initialize

    private func _init() {
        allChildrenUpToRootObject.forEach { (child) in
            DataType.verify(value: child.value)
            switch DataType(key: child.label!, value: child.value) {
            case .file          (let key, _, let file):         file.setParent(self, forKey: key)
            case .collection    (let key, _, let collection):   collection.setParent(self, forKey: key)
            case .list          (let key, _, let list):         list.setParent(self, forKey: key)
            case .reference     (let key, _, let reference):    reference.setParent(self, forKey: key)
            case .relation      (let key, _, let relation):     relation.setParent(self, forKey: key)
            case .document      (let key, _, let object):       object?.setParent(self, forKey: key)
            default: break
            }
        }
    }

    /// Initialize Object
    public override required init() {
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self._createdAt = self.createdAt
        self._updatedAt = self.updatedAt
        self.reference = type(of: self).reference.document()
        self.id = self.reference.documentID
        super.init()
        self._init()
        self._observe()
    }

    /// Initialize the object with the specified ID.
    public convenience required init(id: String) {
        self.init()
        self.id = id
        self.reference = type(of: self).reference.document(id)
    }

    /// Initialize Object from snapshot.
    public convenience required init?(snapshot: DocumentSnapshot) {
        guard let _ = snapshot.data(with: .estimate) else {
            return nil
        }
        self.init()
        _setSnapshot(snapshot)
        self.isSaved = true
    }

    public convenience required init(id: String, value: [String: Any]) {
        self.init()

        self.id = id
        self.reference = type(of: self).reference.document(id)
        initializeWithValues(value)
        self.isSaved = true
    }
    
    
    private func initializeWithValues(_ value: [String: Any]) {
        let data: [String: Any] = value
        
        let formatter: ISO8601DateFormatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]

        self.createdAt = data[(\Object.createdAt)._kvcKeyPathString!] as? Timestamp ?? Timestamp(date: Date())
        self.updatedAt = data[(\Object.createdAt)._kvcKeyPathString!] as? Timestamp ?? Timestamp(date: Date())

        allChildrenUpToRootObject.forEach { (key, value) in
            if let key: String = key {
                if !self.ignore.contains(key) {
                    if self.decode(key, value: data[key]) {
                        return
                    }
                    switch DataType(key: key, value: value, data: data) {
                    case .array             (let key, _, let value):                self.setValue(value, forKey: key)
                    case .set               (let key, _, let value):                self.setValue(value, forKey: key)
                    case .bool              (let key, _, let value):                self.setValue(value, forKey: key)
                    case .binary            (let key, _, let value):                self.setValue(value, forKey: key)
                    case .file              (let key, _, let value):                self.setValue(value, forKey: key); value.setParent(self, forKey: key)
                    case .files             (let key, _, let value):                self.setValue(value, forKey: key); value.forEach { $0.setParent(self, forKey: key) }
                    case .url               (let key, _, let value):                self.setValue(value, forKey: key)
                    case .int               (let key, _, let value):                self.setValue(value, forKey: key)
                    case .float             (let key, _, let value):                self.setValue(value, forKey: key)
                    case .date              (let key, _, let value):                self.setValue(value, forKey: key)
                    case .timestamp         (let key, _, let value):                self.setValue(value, forKey: key)
                    case .geoPoint          (let key, _, let value):                self.setValue(value, forKey: key)
                    case .dictionary        (let key, _, let value):                self.setValue(value, forKey: key)
                    case .documentReference (let key, _, let value):                self.setValue(value, forKey: key)
                    case .collection        (let key, let value, let collection):   collection.setValue(value, forKey: key)
                    case .list              (let key, _, let list):                 list.setParent(self, forKey: key)
                    case .reference         (let key, _, let reference):            reference.setParent(self, forKey: key)
                    case .relation          (let key, _, let relation):             relation.setParent(self, forKey: key)
                    case .document          (let key, let dict, let value):
                        value?.initializeWithValues(dict)
                        value?.setParent(self, forKey: key)
                        self.setValue(value, forKey: key)
                    case .string            (let key, _, let value):                self.setValue(value, forKey: key)
                    case .unknown: break
                    }
                }
            }
        }
        updateValue = [:]
    }

    private func _setSnapshot(_ snapshot: DocumentSnapshot) {
        self.snapshot = snapshot
    }

    public func setReference(_ reference: DocumentReference) {
        self.reference = reference
        allChildrenUpToRootObject.forEach { (key, value) in
            if let key: String = key {
                if !self.ignore.contains(key) {
                    switch DataType(key: key, value: value) {
                    case .file          (let key, _, let value):    value.setParent(self, forKey: key)
                    case .files         (let key, _, let value):    value.forEach { $0.setParent(self, forKey: key) }
                    case .collection    (let key, _, let collection):   collection.setParent(self, forKey: key)
                    case .list          (let key, _, let list):         list.setParent(self, forKey: key)
                    case .reference     (let key, _, let reference):    reference.setParent(self, forKey: key)
                    case .relation      (let key, _, let relation):     relation.setParent(self, forKey: key)
                    case .document      (let key, _, let object):       object?.setParent(self, forKey: key)
                    default: break
                    }
                }
            }
        }
    }

    public var snapshot: DocumentSnapshot? {
        didSet {
            if let snapshot: DocumentSnapshot = snapshot {

                self.reference = snapshot.reference
                self.id = snapshot.documentID

                guard let data: [String: Any] = snapshot.data(with: .estimate) else  {
                    return
                }
                initializeWithValues(data)
                _observe()
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
    public var rawValue: [String: Any] {
        var document: [String: Any] = [:]

        self._properties.forEach { (key, value) in
            if !self.ignore.contains(key) {
                if let rawValue: Any = self.encode(key, value: value) {
                    document[key] = rawValue
                    return
                }
                switch DataType(key: key, value: value) {
                case .array             (let key, let rawValue, _):   document[key] = rawValue
                case .set               (let key, let rawValue, _):   document[key] = rawValue
                case .bool              (let key, let rawValue, _):   document[key] = rawValue
                case .binary            (let key, let rawValue, _):   document[key] = rawValue
                case .file              (let key, let rawValue, _):   document[key] = rawValue
                case .files             (let key, let rawValue, _):   document[key] = rawValue
                case .url               (let key, let rawValue, _):   document[key] = rawValue
                case .int               (let key, let rawValue, _):   document[key] = rawValue
                case .float             (let key, let rawValue, _):   document[key] = rawValue
                case .date              (let key, let rawValue, _):   document[key] = rawValue
                case .timestamp         (let key, let rawValue, _):   document[key] = rawValue
                case .geoPoint          (let key, let rawValue, _):   document[key] = rawValue
                case .dictionary        (let key, let rawValue, _):   document[key] = rawValue
                case .collection        (let key, let rawValue, _):   if !rawValue.isEmpty { document[key] = rawValue }
                case .list              (let key, let rawValue, _):   document[key] = rawValue
                case .documentReference (let key, let rawValue, _):   document[key] = rawValue
                case .reference         (let key, let rawValue, _):   document[key] = rawValue
                case .relation          (let key, let rawValue, _):   document[key] = rawValue
                case .string            (let key, let rawValue, _):   document[key] = rawValue
                case .document          (let key, let rawValue, _):   document[key] = rawValue
                case .unknown: break
                }
            }
        }
        return document
    }

    /// Object value
    public var value: [String: Any] {
        var value: [String: Any] = self.rawValue
        if isSaved {
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

        let keys: [String] = allChildrenUpToRootObject.compactMap({ return $0.label })
        if keys.contains(keyPath) {

            if let value: Any = object.value(forKey: keyPath) as Any? {

                if let updateValue: Any = self.encode(keyPath, value: value) {
                    update(key: keyPath, value: updateValue)
                    return
                }

                switch DataType(key: keyPath, value: value) {
                case .array         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .set           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .bool          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .binary        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .file          (let key, _, _):
                    if let change: [NSKeyValueChangeKey: Any] = change as [NSKeyValueChangeKey: Any]? {
                        guard let currentFile: File = change[.newKey] as? File else {
                            return
                        }
                        currentFile.parent = self
                        currentFile.key = key

                        if currentFile.deleteRequest {
                            self.update(key: key, value: FieldValue.delete())
                        }

                        if let index: Int = self.garbages.index(of: currentFile) {
                            self.garbages.remove(at: index)
                        }

                        if let previousFile: File = change[.oldKey] as? File {
                            previousFile.setParent(self, forKey: key)
                            self.garbages.append(previousFile)
                        }
                    }
                case .files         (let key, _, _):
                    if let change: [NSKeyValueChangeKey: Any] = change as [NSKeyValueChangeKey: Any]? {
                        let oldFiles: [File] = change[.oldKey] as? [File] ?? []
                        guard let newFiles: [File] = change[.newKey] as? [File] else {
                            self.garbages = self.garbages + oldFiles
                            self.update(key: key, value: FieldValue.delete())
                            return
                        }

                        let new: Set<File> = Set(newFiles)
                        let old: Set<File> = Set(oldFiles)

                        if new.isEmpty {
                            self.update(key: key, value: [])
                        }

                        new.subtracting(old).forEach { file in
                            file.setParent(self, forKey: key)
                            if let index: Int = self.garbages.index(of: file) {
                                self.garbages.remove(at: index)
                            }
                        }
                        old.subtracting(new).forEach { file in
                            file.setParent(self, forKey: key)
                            self.garbages.append(file)
                        }

                        newFiles.forEach { (file) in
                            if file.deleteRequest {
                                file.setParent(self, forKey: key)
                                self.garbages.append(file)
                            }
                        }
                        self.update(key: key, value: newFiles.filter { $0.deleteRequest == false }.map { $0.value })
                    }
                case .url               (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .int               (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .float             (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .date              (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .timestamp         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .geoPoint          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .dictionary        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .documentReference (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .collection        (_, _, _):   break
                case .list              (_, _, _):   break
                case .reference         (_, _, _):   break
                case .relation          (_, _, _):   break
                case .document          (let key, let updateValue, let object):
                    update(key: key, value: updateValue)
                    object?.setParent(self, forKey: key)
                case .string        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .unknown: break
                }
            } else {
                update(key: keyPath, value: NSNull())
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    public var updateValue: [String: Any] = [:]

    internal var garbages: [File] = []

    /**
     Update the data on Firebase.
     When this function is called, updatedAt of Object is updated at the same time.

     - parameter key: Document field name
     - parameter value: Save to value. If you enter nil
     */
    public func update(key: String, value: Any) {
        updateValue[key] = value
        if let parent = self.parent, let key = self.key{
            parent.setValue(self, forKey: key)
        }
    }

    /**
     Pack will pass data to Batch to save the data.
     */
    @discardableResult
    public func pack(_ type: BatchType, batch: WriteBatch) -> WriteBatch {
        if self._hash == batch.hash {
            return batch
        }
        self._hash = batch.hash
        switch type {
        case .save:
            batch.setData(self.value , forDocument: self.reference)
            self._properties.forEach({ (key, value) in
                if let value = value {
                    switch DataType(key: key, value: value) {
                    case .collection(_, _, let collection):
                        collection.pack(type, batch: batch)
                    case .reference(_, _, let reference):
                        if reference is Batchable {
                            (reference as! Batchable).pack(type, batch: batch)
                        }
                    case .relation(_, _, let relation):
                        if relation is Batchable {
                            (relation as! Batchable).pack(type, batch: batch)
                        }
                    default: break
                    }
                }
            })
        case .update:
            var updateValue: [String: Any] = self.updateValue
            self._properties.forEach({ (key, value) in
                if let value = value {
                    switch DataType(key: key, value: value) {
                    case .collection(_, _, let collection):
                        collection.pack(type, batch: batch)
                    case .list(let key, _, let list):
                        let listUpdateValue: [String: Any] = list.updateValue
                        if !listUpdateValue.isEmpty {
                            updateValue[key] = list.updateValue
                        }
                    case .reference(_, _, let reference):
                        if reference is Batchable {
                            (reference as! Batchable).pack(type, batch: batch)
                        }
                    case .relation(_, _, let relation):
                        if relation is Batchable {
                            (relation as! Batchable).pack(type, batch: batch)
                        }
                    default: break
                    }
                }
            })
            if self.isSaved {
                if !updateValue.isEmpty {
                    updateValue[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
                    batch.setData(updateValue, forDocument: self.reference, merge: true)
                }
            } else {
                batch.setData(self.value , forDocument: self.reference)
            }
        case .delete:
            batch.deleteDocument(self.reference)
        }
        return batch
    }

    public func batch(_ type: BatchType, completion batchID: String) {
        if batchID == self.batchID {
            return
        }
        self.batchID = batchID
        self.isSaved = true
        self._properties.forEach({ (key, value) in
            if let value = value {
                switch DataType(key: key, value: value) {
                case .collection(_, _, let collection):
                    collection.batch(type, completion: batchID)
                case .reference(_, _, let reference):
                    if reference is Batchable {
                        (reference as! Batchable).batch(type, completion: batchID)
                    }
                case .relation(_, _, let relation):
                    if relation is Batchable {
                        (relation as! Batchable).batch(type, completion: batchID)
                    }
                default: break
                }
            }
        })
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
        if isSaved {
            fatalError("[Pring.Document] *** error: \(type(of: self)) has already been saved.")
        }
        let ref: DocumentReference = self.reference
        if self.shouldUploadFiles(UUID().uuidString) {
            return self.saveFiles(UUID().uuidString, container: nil) { (error) in
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
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        self.pack(.save, batch: batch).commit { (error) in
            if let error: Error = error {
                block?(nil, error)
                return
            }
            self.batch(.save, completion: UUID().uuidString)
            block?(self.reference, nil)
        }
    }

    // MARK: UPDATE
    @discardableResult
    public func update(_ block: ((Error?) -> Void)? = nil)  -> [String: StorageUploadTask] {
        return self.update(nil, block: block)
    }

    @discardableResult
    public func update(_ batch: WriteBatch? = nil, block: ((Error?) -> Void)? = nil) -> [String: StorageUploadTask] {
        if self.shouldUploadFiles(UUID().uuidString) {
            return self.saveFiles(UUID().uuidString, container: nil) { (error) in
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
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        self.pack(.update, batch: batch).commit { (error) in
            if let error: Error = error {
                block?(error)
                return
            }
            self.batch(.update, completion: UUID().uuidString)
            self.garbages._dispose({ (error) in
                self.reset()
                block?(nil)
            })
        }
    }

    private func _dispose() {

    }

    // MARK: DELETE

    public func delete(_ block: ((Error?) -> Void)? = nil) {
        self.delete(nil, block: block)
    }

    public func delete(_ batch: WriteBatch? = nil, block: ((Error?) -> Void)? = nil) {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        self.deleteFiles(UUID().uuidString, container: nil) { (error) in
            self.pack(.delete, batch: batch).commit { (error) in
                if let error = error {
                    block?(error)
                    return
                }
                self.reset()
                block?(nil)
            }
        }
    }

    internal func reset() {
        self.updateValue = [:]
        self._properties.forEach { (key, value) in
            if !self.ignore.contains(key) {
                switch DataType(key: key, value: value) {
                case .file(let key, _, let file):
                    if file.deleteRequest {
                        self[key] = nil
                    }
                    if file.isDeleted {
                        self[key] = nil
                    }
                case .files(_, _, let files):
                    if !files.isEmpty {
                        self[key] = files.filter { return !$0.deleteRequest }
                    }
                default: break
                }
            }
        }
    }

    // MARK: -

    override open var description: String {
        let base: String =
            "  id: \(self.id)\n" +
            "  createdAt: \(self.createdAt)\n" +
            "  updatedAt: \(self.updatedAt)\n"

        let values: String = allChildrenUpToRootObject.reduce(base) { (result, children) -> String in
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

    private var _properties: [String: Any?] {
        var properties: [String: Any?] = [:]
        allChildrenUpToRootObject.forEach { (key, value) in
            if let key: String = key {
                properties[key] = value
            }
        }
        return properties
    }

    // MARK: Deinit

    deinit {
        if self.isObserving {
            allChildrenUpToRootObject.forEach { (key, value) in
                if let key: String = key {
                    if !self.ignore.contains(key) {
                        switch DataType(key: key, value: value) {
                        case .collection, .reference, .relation: break
                        default:
                            self.removeObserver(self, forKeyPath: key)
                        }
                    }
                }
            }
        }
    }
}

extension Object {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? Object else {
            return false
        }
        return self == obj
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
