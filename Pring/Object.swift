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

    open static var version: Int {
        return 1
    }

    open static var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    open static var path: String {
        return "version/\(self.version)/\(self.modelName)"
    }

    open static var reference: CollectionReference {
        return Firestore.firestore().collection("version").document("\(self.version)").collection(self.modelName)
    }

    open static var storageRef: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public var path: String {
        return self.reference.path
    }

    private var _reference: DocumentReference

    public var reference: DocumentReference {
        return _reference
    }

    /// It is Qeueu of File upload.
    public let uploadQueue: DispatchQueue = DispatchQueue(label: "Pring.upload.queue")

    public var id: String

    @objc public var createdAt: Date

    @objc public var updatedAt: Date

    public private(set) var isListening: Bool = false

    private var hasFiles: Bool {
        let mirror = Mirror(reflecting: self)
        for (_, child) in mirror.children.enumerated() {
            if let key: String = child.label {
                switch DataType(key: key, value: child.value) {
                case .file(_, _, _): return true
                default: break
                }
                return true
            }
        }
        return false
    }

    // MARK: - Initialize

    private func _init() {
        let mirror: Mirror = Mirror(reflecting: self)
        mirror.children.forEach { (child) in
            if child.value is ReferenceCollection {
                var relation: ReferenceCollection = child.value as! ReferenceCollection
                relation.parent = self
                relation.key = child.label
            }
        }
    }

    /// Initialize Object
    public override init() {
        self.createdAt = Date()
        self.updatedAt = Date()
        self._reference = type(of: self).reference.document()
        self.id = self._reference.documentID
        super.init()
        self._init()
    }

    /// Initialize the object with the specified ID.
    public convenience required init(id: String) {
        self.init()
        self.id = id
        self._reference = type(of: self).reference.document(id)
    }

    /// Initialize Object from snapshot.
    public convenience required init(snapshot: DocumentSnapshot) {
        self.init()
        _setSnapshot(snapshot)
    }

    func _setSnapshot(_ snapshot: DocumentSnapshot) {
        self.snapshot = snapshot
    }

    public var snapshot: DocumentSnapshot? {
        didSet {
            if let snapshot: DocumentSnapshot = snapshot {

                self._reference = snapshot.reference
                self.id = snapshot.documentID

                let data: [String: Any] = snapshot.data()

                self.createdAt = snapshot[(\Object.createdAt)._kvcKeyPathString!] as! Date
                self.updatedAt = snapshot[(\Object.updatedAt)._kvcKeyPathString!] as! Date

                Mirror(reflecting: self).children.forEach { (key, value) in
                    if let key: String = key {
                        if !self.ignore.contains(key) {
                            if let _: Any = self.decode(key, value: data[key]) {
                                self.addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
                                return
                            }
                            switch DataType(key: key, value: value) {
                            case .array         (let key, _, let value):                self.setValue(value, forKey: key)
                            case .set           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .bool          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .binary        (let key, _, let value):                self.setValue(value, forKey: key)
                            case .file          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .url           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .int           (let key, _, let value):                self.setValue(value, forKey: key)
                            case .float         (let key, _, let value):                self.setValue(value, forKey: key)
                            case .date          (let key, _, let value):                self.setValue(value, forKey: key)
                            case .geoPoint      (let key, _, let value):                self.setValue(value, forKey: key)
                            case .dictionary    (let key, _, let value):                self.setValue(value, forKey: key)
                            case .relation      (let key, let value, let relation):     relation.setValue(value, forKey: key)
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
    open func decode(_ key: String, value: Any?) -> Any? {
        return nil
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
                    case .relation      (let key, let rawValue, _):   document[key] = rawValue
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

    // MARK: - Save
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
            return self.saveFiles { (error) in
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
        self.pack().commit { [weak self] (error) in
            self?.reference.getDocument(completion: { (snapshot, error) in
                self?.snapshot = snapshot
                block?(snapshot?.reference, error)
            })
        }
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
                        guard let new: File = change[.newKey] as? File else {
                            if let old: File = change[.oldKey] as? File {
                                old.parent = self
                                old.key = key
                                old.remove()
                            }
                            return
                        }
                        if let old: File = change[.oldKey] as? File {
                            if old.name != new.name {
                                new.parent = self
                                new.key = key
                                old.parent = self
                                old.key = key
                            }
                        } else {
                            new.parent = self
                            new.key = key
                        }
                    }
                case .url           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .int           (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .float         (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .date          (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .geoPoint      (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .dictionary    (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .relation      (_, _, _):   break
                case .string        (let key, let updateValue, _):   update(key: key, value: updateValue)
                case .null: break
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    /**
     Update the data on Firebase.
     When this function is called, updatedAt of Object is updated at the same time.

     - parameter key: Document field name
     - parameter value: Save to value. If you enter nil
     */
    internal func update(key: String, value: Any) {
        self.reference.updateData([
            key : value,
            (\Object.updatedAt)._kvcKeyPathString!: FieldValue.serverTimestamp()
            ])
    }

    /**

    */
    @discardableResult
    public func pack(_ batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        batch.setData(self.value as! [String : Any], forDocument: self.reference)
        let mirror: Mirror = Mirror(reflecting: self)
        mirror.children.forEach { (child) in
            if let relation: ReferenceCollection = child.value as? ReferenceCollection {
                relation.pack(batch)
            }
        }
        return batch
    }

    // MARK: - File

    open var timeout: Int {
        return 30
    }

    /**
     Save the file set in the object.

     - parameter block: If saving succeeds or fails, this callback will be called.
     - returns: Returns the StorageUploadTask set in the property.
     */
    private func saveFiles(_ block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {

        let group: DispatchGroup = DispatchGroup()
        var uploadTasks: [String: StorageUploadTask] = [:]

        var hasError: Error? = nil

        for (_, child) in Mirror(reflecting: self).children.enumerated() {

            guard let key: String = child.label else { break }
            if self.ignore.contains(key) { break }
            let value = child.value

            let mirror: Mirror = Mirror(reflecting: value)
            let subjectType: Any.Type = mirror.subjectType
            if subjectType == File?.self || subjectType == File.self {
                if let file: File = value as? File {
                    file.parent = self
                    file.key = key
                    group.enter()
                    if let task: StorageUploadTask = file.save(key, completion: { (meta, error) in
                        if let error: Error = error {
                            hasError = error
                            uploadTasks.forEach({ (_, task) in
                                task.cancel()
                            })
                            return
                        }
                        group.leave()
                    }) {
                        uploadTasks[key] = task
                    }
                }
            }
        }

        uploadQueue.async {
            group.notify(queue: DispatchQueue.main, execute: {
                block?(hasError)
            })
            switch group.wait(timeout: .now() + .seconds(self.timeout)) {
            case .success: break
            case .timedOut:
                uploadTasks.forEach({ (_, task) in
                    task.cancel()
                })
                let error: DocumentError = DocumentError(kind: .timeout, description: "Save the file timeout.")
                DispatchQueue.main.async {
                    block?(error)
                }
            }
        }
        return uploadTasks
    }

    // MARK: - delete

    public class func delete(id: String, block: ((Error?) -> Void)? = nil) {
        self.reference.document(id).delete(completion: block)
    }

    public func delete(_ block: ((Error?) -> Void)? = nil) {
        self.reference.delete(completion: block)
    }

    // MARK: -

    override open var description: String {

        let base: String =
            "  key: \(self.id)\n" +
            "  createdAt: \(self.createdAt)\n" +
            "  updatedAt: \(self.updatedAt)\n"

        let values: String = Mirror(reflecting: self).children.reduce(base) { (result, children) -> String in
            guard let label: String = children.0 else {
                return result
            }
            return result + "  \(label): \(children.1)\n"
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
        print("deinit", self)
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

extension Sequence where Iterator.Element: Document {
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
