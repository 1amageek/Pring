//
//  User.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

@objcMembers
class User: Object {

    @objc enum UserType: Int {
        case normal
        case gold
        case premium
    }

//    enum Media: String, AnyContentType {
//
//        case photo
//
//        var model: Object.Type {
//            switch self {
//            case .photo: return Photo.self
//            }
//        }
//    }

    dynamic var type: UserType = .normal
    dynamic var name: String?
    dynamic var thumbnail: File?
    dynamic var followers: ReferenceCollection<User> = []
    dynamic var friends: ReferenceCollection<User> = []
    dynamic var items: NestedCollection<Item> = []

//    dynamic var content: Media?

    static func image() -> UIImage {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.green.cgColor)
        context.fill(frame)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
