//
//  ContentType.swift
//  Pring
//
//  Created by 1amageek on 2017/11/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


protocol AnyContentType: RawRepresentable { }

extension AnyContentType where Self.RawValue == String {

    func get<T: Document>(_ type: T.Type, id: String, block: @escaping (T?, Error?) -> Void) {
        T.get(id, block: block)
    }
}

protocol MultipleReference {
    associatedtype ContentType: AnyContentType
    var id: String? { get }
}

extension MultipleReference {

    func get<T: Document>(_ type: T.Type, block: @escaping (T?, Error?) -> Void) {
        guard let id: String = self.id else {
            block(nil, nil) // TODO: Error Handling
            return
        }
        type.get(id, block: block)
    }
}

//class Media: MultipleReference {
//
//    enum ContentType: String, AnyContentType {
//        case photo
//
//        var model: Object.Type {
//            switch self {
//            case .photo: return Photo.self
//            }
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
//
////class Hoge: Object {
////
////    var media: Media?
////}
//
//
//let item: Media = Media()
//item.get(<#T##type: Document.Protocol##Document.Protocol#>, block: <#T##(Document?, Error?) -> Void#>)

