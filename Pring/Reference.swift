//
//  Reference.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol HasParent {

    weak var parent: Object? { get }

    var key: String? { get }

    func setParent(_ object: Object, forKey key: String)
}

public protocol ReferenceRawValue: HasParent {

    var rawValue: [AnyHashable: Any]? { get }

    init(rawValue: [AnyHashable: Any]?)

    func setRawValue(rawValue: [AnyHashable: Any]?)
}

public protocol AnyReference: ReferenceRawValue {

    var id: String? { get }

    var contentType: String? { get }

    var value: [AnyHashable: Any] { get }
}

public class ReferencePlaceholder: AnyReference {

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    internal var _id: String? {
        return self.rawValue?["id"] as? String
    }

    internal var _contentType: String? {
        return self.rawValue?["contentType"] as? String
    }

    public var id: String? {
        return _id
    }

    public var contentType: String? {
        return _contentType
    }

    public internal(set) var rawValue: [AnyHashable: Any]?

    public init() {

    }

    public required convenience init(rawValue: [AnyHashable : Any]?) {
        self.init()
        self.rawValue = rawValue
    }

    public var value: [AnyHashable: Any] {
        guard let id: String = self.id, let contentType: String = self.contentType else { return [:] }
        return [
            "id": id,
            "contentType": contentType
        ]
    }

    public func setRawValue(rawValue: [AnyHashable : Any]?) {
        self.rawValue = rawValue
    }

    public func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }
}

public class Reference<T: Document>: ReferencePlaceholder {

    public typealias ContentType = T

    var object: ContentType?

    public override var id: String? {
        return self.object?.id ?? _id
    }

    public override var contentType: String? {
        return ContentType.modelName
    }

    public var content: ContentType? {
        return self.object
    }

    public override init() {

    }

    public required convenience init(rawValue: [AnyHashable : Any]?) {
        self.init()
        self.rawValue = rawValue
    }

    public convenience init?(_ object: ContentType) {
        self.init(rawValue: nil)
        self.object = object
    }

    public func pack(_ type: BatchType, batch: WriteBatch?) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        if let document = self.object {
            batch.setData(document.value as! [String : Any], forDocument: document.reference)
        }
        return batch
    }

    public func get(_ block: @escaping (ContentType?, Error?) -> Void) {
        guard let id: String = self.id else {
            block(nil, nil) // TODO: Error handling
            return
        }
        ContentType.get(id) { (document, error) in
            self.object = document
            block(document, error)
        }
    }
}

public protocol AnyContentType: RawRepresentable {

}

public class MultipleReference<T: AnyContentType>: ReferencePlaceholder where T.RawValue == String {

    public typealias ContentType = T

    var object: Object?

    public override var id: String? {
        return self.object?.id ?? _id
    }

    public override var contentType: String? {
        guard let object = self.object else {
            return _contentType
        }
        return type(of: object).modelName
    }

    public var content: ContentType? {
        guard let contentType: String = self.contentType else {
            return nil
        }
        return ContentType(rawValue: contentType)
    }

    public var modelName: String? {
        guard let object: Object = self.object else {
            return _contentType
        }
        return type(of: object).modelName
    }

    public override init() {

    }

    public required convenience init(rawValue: [AnyHashable : Any]?) {
        self.init()
        self.rawValue = rawValue
    }

    public func pack(_ type: BatchType, batch: WriteBatch?) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        if let document = self.object {
            batch.setData(document.value as! [String : Any], forDocument: document.reference)
        }
        return batch
    }
}
