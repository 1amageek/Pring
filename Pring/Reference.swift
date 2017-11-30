//
//  Reference.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


public protocol AnyContentType: RawRepresentable {
    var model: Object.Type { get }
}

extension AnyContentType where Self.RawValue == String {

    var model: Object.Type {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let cls: AnyClass = NSClassFromString("\(namespace).\(self.rawValue)")!
        return cls as! Object.Type
    }

    func get<T: Document>(_ type: T.Type, id: String, block: @escaping (T?, Error?) -> Void) {
        T.get(id, block: block)
    }
}

public protocol AnyReference: Batchable {

//    associatedtype ContentType = Void

    var parent: Object? { set get }

    var key: String? { set get }

    var id: String? { get }

    var contentType: String? { get }

    var value: [AnyHashable: Any] { get }

    func setValue(_ value: [AnyHashable: Any]?)

    func setParent(_ object: Object, forKey key: String)
}

//private var ReferenceContentID      = 0
//
//private var ReferenceContentType    = 1
//
//extension Reference {
//
//    private var _id: String? {
//        return objc_getAssociatedObject(self, &ReferenceContentID) as? String
//    }
//
//    private var _contentType: String? {
//        return objc_getAssociatedObject(self, &ReferenceContentType) as? String
//    }
//
//    public var id: String? {
//        return self.object?.id ?? _id
//    }
//
//    public var contentType: String? {
//        guard let object: Object = self.object else {
//            return _contentType
//        }
//        return type(of: object).modelName
//    }
//
//    public func setValue(_ value: Any?, forKey key: String) {
//
//        guard let value: [String: String] = value as? [String: String] else { return }
//        guard let id: String = value["id"], let contentType: String = value["contentType"] else { return }
//
//        objc_setAssociatedObject(self, &ReferenceContentID, id, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        objc_setAssociatedObject(self, &ReferenceContentType, contentType, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//    }
//
//}
//

//extension AnyReference where Self.ContentType: AnyContentType {
//
//}

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

    public var contentType: String? {
        guard let object: ContentType = self.object else {
            return _contentType
        }
        return type(of: object).modelName
    }

    public var value: [AnyHashable: Any] {
        guard let id: String = self.id, let contentType: String = self.contentType else { return [:] }
        return [
            "id": id,
            "contentType": contentType
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
}

//open class MultipleReference: AnyReference {
//
//    public private(set) var rawValue: [String: String]?
//
//    var object: Object?
//
//    private var _id: String? {
//        return self.rawValue?["id"]
//    }
//
//    private var _contentType: String? {
//        return self.rawValue?["contentType"]
//    }
//
//    public var id: String? {
//        return self.object?.id ?? _id
//    }
//
//    public var contentType: String? {
//        guard let object: Object = self.object else {
//            return _contentType
//        }
//        return type(of: object).modelName
//    }
//
//    public var value: [AnyHashable: Any] {
//        guard let id: String = self.id, let contentType: String = self.contentType else { return [:] }
//        return [
//            "id": id,
//            "contentType": contentType
//        ]
//    }
//
//    public func setValue(_ value: Any?) {
//        guard let value: [String: String] = value as? [String: String] else { return }
//        self.rawValue = value
//    }
//}

//public protocol MultipleReference: Reference {
//
//    associatedtype ContentType: AnyContentType
//
//    var multipleContentType: ContentType? { get }
//}
//
//extension MultipleReference where ContentType.RawValue == String {
//
//    var id: String? {
//        return self.object?.id
//    }
//
//    var multipleContentType: ContentType? {
//        guard let object: Object = self.object else {
//            return nil
//        }
//        return ContentType(rawValue: type(of: object).modelName)
//    }
//
//    func get<T: Document>(_ type: T.Type, block: @escaping (T?, Error?) -> Void) {
//        guard let id: String = self.id else {
//            block(nil, nil) // TODO: Error Handling
//            return
//        }
//        type.get(id, block: block)
//    }
//}

//protocol AnyContentType: RawRepresentable {
//    var model: Object.Type { get }
//}
//
//extension AnyContentType where Self.RawValue == String {
//
//    init?(rawValue: Self.RawValue) {
//        super.init(rawValue: rawValue)
//    }
//
//    init?(_ object: Object) {
//        let modelName: String = Swift.type(of: object).modelName
//        self.init(rawValue: modelName)
//    }
//
//    func get<T: Document>(id: String, block: @escaping (T?, Error?) -> Void) {
//        let type: T.Type = self.model as! T.Type
//        type.get(id, block: block)
//    }
//
////    var model: Object.Type {
////        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
////        let cls: AnyClass = NSClassFromString("\(namespace).\(self.rawValue)")!;
////        return cls as! Object.Type
////    }
////
////    func get<T: Document>(_ type: T.Type, id: String, block: @escaping (T?, Error?) -> Void) {
////        T.get(id, block: block)
////    }
//}

//protocol MultipleReference {
//    associatedtype ContentType: AnyContentType
//
//    var id: String? { get }
//
//    var contentType: ContentType? { get }
//}
//
//extension MultipleReference {
//
//    func get<T: Document>(_ type: T.Type, block: @escaping (T?, Error?) -> Void) {
//        guard let id: String = self.id else {
//            block(nil, nil) // TODO: Error Handling
//            return
//        }
//        type.get(id, block: block)
//    }
//}
//
//
//class Media: MultipleReference {
//
//    enum ContentType: String, AnyContentType {
//        case photo
//
//        var model: Object.Type {
//            let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
//            let cls: AnyClass = NSClassFromString("\(namespace).\(self.rawValue)")!;
//            return cls as! Object.Type
//        }
//    }
//
//    var id: String?
//
//    var contentType: ContentType?
//}
//
//
//class Photo: Object {
//
//}

//class Hoge: Object {
//
//    var media: Media?
//}


//
//
//let item: Media = Media()
//item.get(<#T##type: Document.Protocol##Document.Protocol#>, block: <#T##(Document?, Error?) -> Void#>)


