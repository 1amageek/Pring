//
//  Reference.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


public protocol AnyReference: Batchable {

    var parent: Object? { set get }

    var key: String? { set get }

    var id: String? { get }

    var modelName: String? { get }

    var value: [AnyHashable: Any] { get }

    func setValue(_ value: [AnyHashable: Any]?)

    func setParent(_ object: Object, forKey key: String)
}

open class Reference<T: Document>: NSObject, AnyReference {

    public typealias ContentType = T

    public private(set) var rawValue: [String: String]?

    var object: ContentType?

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    private var _id: String? {
        return self.rawValue?["id"]
    }

    private var _contentType: String? {
        return self.rawValue?["contentType"]
    }

    public var id: String? {
        return self.object?.id ?? _id
    }

    public var contentType: ContentType? {
        return self.object
    }

    public var modelName: String? {
        return ContentType.modelName
    }

    public var value: [AnyHashable: Any] {
        guard let id: String = self.id, let modelName: String = self.modelName else { return [:] }
        return [
            "id": id,
            "contentType": modelName
        ]
    }

    public override init() {
        super.init()
    }

    public convenience init?(_ object: ContentType) {
        self.init()
        self.object = object
    }

    public func setValue(_ value: [AnyHashable : Any]?) {
        guard let value: [String: String] = value as? [String: String] else { return }
        self.rawValue = value
    }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    public func pack(_ type: BatchType, batch: WriteBatch?) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        if let document: ContentType = self.object {
            batch.setData(document.value as! [String : Any], forDocument: document.reference)
        }
        return batch
    }

    public func get(_ block: @escaping (ContentType?, Error?) -> Void) {
        guard let id: String = self.id else {
            block(nil, nil) // TODO: Error handling
            return
        }
        ContentType.get(id, block: block)
    }
}

public protocol AnyContentType: RawRepresentable {

}

open class MultipleReference<T: AnyContentType>: NSObject, AnyReference where T.RawValue == String {

    public typealias ContentType = T

    public private(set) var rawValue: [String: String]?

    var object: Object?

    public var parent: Object?

    public var key: String?

    private var _id: String? {
        return self.rawValue?["id"]
    }

    private var _contentType: String? {
        return self.rawValue?["contentType"]
    }

    public var id: String? {
        return self.object?.id ?? _id
    }

    public var contentType: ContentType? {
        guard let modelName: String = self.modelName else {
            return nil
        }
        return ContentType(rawValue: modelName)
    }

    public var modelName: String? {
        guard let object: Object = self.object else {
            return _contentType
        }
        return type(of: object).modelName
    }

    public var value: [AnyHashable: Any] {
        guard let id: String = self.id, let modelName: String = self.modelName else { return [:] }
        return [
            "id": id,
            "contentType": modelName
        ]
    }

    public override init() {
        super.init()
    }

    public convenience init?(_ object: Object) {
        self.init()
        self.object = object
    }

    public func setValue(_ value: [AnyHashable : Any]?) {
        guard let value: [String: String] = value as? [String: String] else { return }
        self.rawValue = value
    }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    public func pack(_ type: BatchType, batch: WriteBatch?) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        if let document = self.object {
            batch.setData(document.value as! [String : Any], forDocument: document.reference)
        }
        return batch
    }
}


