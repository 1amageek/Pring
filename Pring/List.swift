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

    var updateValue: [String: Any] { get }

    func setValue(_ value: [String: Any])

    func setParent(_ object: Object, forKey key: String)
}

public extension AnyList {

    func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
}

public final class List<T: Document>: AnyList, Collection, ExpressibleByArrayLiteral {

    fileprivate var _storage: [String: T] = [:]

    public typealias ArrayLiteralElement = T

    public typealias Element = T

    public typealias Index = Int

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

    public var updateValue: [String: Any] {
        var updateValue: [String: Any] = [:]
        self.forEach { (document) in
            if !document.updateValue.isEmpty {
                updateValue[document.id] = document.updateValue
            }
        }
        return updateValue
    }

    public func setValue(_ value: [String : Any]) {
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

    public func append(_ object: T) {
        self._storage[object.id] = object
        if let parent: Object = self.parent, let key: String = self.key, parent.isSaved {
            parent.updateValue[key] = [object.id: object.rawValue]
        }
    }

    public func remove(_ object: T) {
        self._storage.removeValue(forKey: object.id)
        if let parent: Object = self.parent, let key: String = self.key, parent.isSaved {
            parent.updateValue[key] = [object.id: FieldValue.delete()]
        }
    }

    public var keys: [String] {
        return self._storage.keys.map { $0 }.sorted()
    }
}

extension List {

    public var count: Int {
        return self._storage.count
    }

    public var isEmpty: Bool {
        return self._storage.isEmpty
    }

    public var first: T? {
        if self.isEmpty { return nil }
        return self._storage[self.keys[self.startIndex]]
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.keys.endIndex
    }

    public subscript(position: String) -> T {
        return self._storage[position]!
    }

    public subscript(position: Int) -> T {
        let position: String = self.keys[position]
        return self._storage[position]!
    }

    public func index(after i: Int) -> Int {
        return self.keys.index(after: i)
    }
}
