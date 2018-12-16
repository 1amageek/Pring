//
//  List.swift
//  Pring
//
//  Created by 1amageek on 2018/12/16.
//  Copyright © 2018 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol AnyList: class {

    var key: String? { get set }

    var parent: Object? { get set }

    var value: [String: Any] { get }

    func setValue(_ value: [String: Any], forKey key: String)

    func setParent(_ object: Object, forKey key: String)
}

public extension AnyList {

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
}

public final class List<T: Document>: AnyList, ExpressibleByArrayLiteral {

    fileprivate var _storage: [String: T] = [:]

    public typealias ArrayLiteralElement = T

    public init(arrayLiteral elements: T...) {
        var storage: [String: T] = [:]
        elements.forEach { (doc) in
            storage[doc.id] = doc
        }
        self._storage = storage
    }

    public var parent: Object?

    public var key: String?

    public var value: [String : Any] {
        var value: [String: Any] = [:]
        self._storage.forEach { (id, object) in
            value[id] = object.rawValue
        }
        return value
    }

    public func setValue(_ value: [String : Any], forKey key: String) {
        var storage: [String: T] = [:]
        value.forEach { (id, data) in
            if let data: [String: Any] = data as? [String: Any] {
                storage[id] = T(id: id, value: data)
            }
        }
        self._storage = storage
    }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    public subscript(id: String) -> T? {
        return self._storage[id]
    }

    public func append(_ object: T) {
        self._storage[object.id] = object
    }

    public func remove(_ object: T) {
        self._storage.removeValue(forKey: object.id)
    }
}

extension Array where Element == Document {

}

//extension List: StorageLinkable {
//
//    public func shouldUploadFiles(_ id: String) -> Bool {
//        for (_, object) in self._storage.enumerated() {
//            if object.value.shouldUploadFiles(id) {
//                return true
//            }
//        }
//        return false
//    }
//
//    public func saveFiles(_ id: String, container: UploadContainer? = nil, block: ((Error?) -> Void)?) -> [String: StorageUploadTask] {
//        let uploadContainer: UploadContainer = container ?? UploadContainer()
//        for (_, object) in self._storage.enumerated() {
//            object.value.saveFiles(id, container: uploadContainer, block: nil)
//        }
//        return uploadContainer.tasks
//    }
//
//    public func deleteFiles(_ id: String, container: DeleteContainer? = nil, block: ((Error?) -> Void)? = nil) {
//        let deleteContainer: DeleteContainer = container ?? DeleteContainer()
//        for (_, object) in self._storage.enumerated() {
//            object.value.deleteFiles(id, container: deleteContainer, block: nil)
//        }
//    }
//}
