//
//  Object.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

open class Object: NSObject, Document {

    open static var modelVersion: Int {
        return 1
    }

    open static var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    open static var path: String {
        return "version/\(self.modelVersion)/\(self.modelName)"
    }

    open static var reference: CollectionReference {
        return Firestore.firestore().collection("version").document("\(self.modelVersion)").collection(self.modelName)
    }

    open static var storageRef: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public private(set) var reference: DocumentReference

    public var path: String {
        return self.reference.path
    }

    /// It is Qeueu of File upload.
    public let uploadQueue: DispatchQueue = DispatchQueue(label: "Pring.upload.queue")

    @objc public var id: String

    @objc public var createdAt: Date

    @objc public var updatedAt: Date {
        didSet {
            _updatedAt = updatedAt
        }
    }

    ///  https://github.com/firebase/firebase-ios-sdk/issues/364
    @objc private var _updatedAt: Date

    public private(set) var isListening: Bool = false

    // MARK: - Initialize

    private func _init() {
        let mirror: Mirror = Mirror(reflecting: self)
        mirror.children.forEach { (child) in
            DataType.verify(value: child.value)
            switch DataType(key: child.label!, value: child.value) {
            case .file(let key, _, let file): file.parent = self; file.key = key
            case .collection(let key, _, var collection): collection.parent = self; collection.key = key
            default: break
            }
        }
    }

    /// Initialize Object
    public override init() {
        self.createdAt = Date()
        self.updatedAt = Date()
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

    func _setSnapshot(_ snapshot: DocumentSnapshot) {
        self.snapshot = snapshot
    }

    internal func set(_ reference: DocumentReference) {
        print(reference.path)
        self.reference = reference
    }

    public var snapshot: DocumentSnapshot? {
        didSet {
            if let snapshot: DocumentSnapshot = snapshot {

                self.reference = snapshot.reference
                self.id = snapshot.documentID

                let data: [String: Any] = snapshot.data()

                self.createdAt = data[(\Object.createdAt)._kvcKeyPathString!] as! Date
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
                            case .file          (let key, _, let value):                self.setValue(value, forKey: key); value.parent = self; value.key = key
                            case .url           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .int           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .float         (let key, _, let value):                self.setValue(value, forKey: key)
                            case .date          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .geoPoint      (let key, _, let value):                self.setValue(value, forKey: key)
                            case .dictionary    (let key, _, let value):                self.setValue(value, forKey: key)
                            case .collection    (let key, let value, let collection):   collection.setValue(value, forKey: key)
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
                    switch DataType(key: key, value: value) {
                    case .array         (let key, let rawValue, _):   document[key] = rawValue
                    case .set           (let key, let rawValue, _):   document[key] = rawValue
                    case .bool          (let key, let rawValue, _):   document[key] = rawValue
                    case .binary        (let key, let rawValue, _):   document[key] = rawValue
                    case .file          (let key, let rawValue, _):   document[key] = rawValue
                    case .url           (let key, let rawValue, _):   document[key] = rawValue
                    case .int           (let key, let rawValue, _):   document[key] = rawValue
                    case .float         (let key, let rawValue, _):   document[key] = rawValue
                    case .date          (let key, let rawValue, _):   document[key] = rawValue
                    case .geoPoint      (let key, let rawValue, _):   document[key] = rawValue
                    case .dictionary    (let key, let rawValue, _):   document[key] = rawValue
                    case .collection    (let key, let rawValue, _):   document[key] = rawValue
                    case .string        (let key, let rawValue, _):   document[key] = rawValue
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
        value[(\Object.createdAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
        value[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
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
                case .url           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .int           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .float         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .date          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .geoPoint      (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .dictionary    (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .collection    (_, _, _):   break
                case .string        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .null: break
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    internal var updateValue: [AnyHashable: Any] = [:]

    /**
     Update the data on Firebase.
     When this function is called, updatedAt of Object is updated at the same time.

     - parameter key: Document field name
     - parameter value: Save to value. If you enter nil
     */
    internal func update(key: String, value: Any) {
        updateValue[key] = value
    }

    /**

     */
    @discardableResult
    public func pack(_ batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        batch.setData(self.value as! [String : Any], forDocument: self.reference)
        let mirror: Mirror = Mirror(reflecting: self)
        mirror.children.forEach { (child) in
            if let relation: SubCollection = child.value as? SubCollection {
                relation.pack(batch)
            }
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
                self._save(block)
            }
        } else {
            _save(block)
            return [:]
        }
    }

    private func _save(_ block: ((DocumentReference?, Error?) -> Void)?) {
        self.pack().commit { (error) in
            self.reference.getDocument(completion: { (snapshot, error) in
                self.snapshot = snapshot
                block?(snapshot?.reference, error)
            })
        }
    }

    // MARK: UPDATE

    public func update(_ block: ((Error?) -> Void)? = nil) {
        updateValue[(\Object.updatedAt)._kvcKeyPathString!] = FieldValue.serverTimestamp()
        let batch: WriteBatch = self.reference.firestore.batch()
        batch.updateData(updateValue, forDocument: self.reference)
        batch.commit(completion: { (error) in
            self.updateValue = [:]
            block?(error)
        })
    }

    // MARK: DELETE

    public func delete(_ block: ((Error?) -> Void)? = nil) {
        self.reference.delete { (error) in
            if let error = error {
                block?(error)
                return
            }
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

extension Object: StorageLinkable {
    
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
