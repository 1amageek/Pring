//
//  User.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring

@objcMembers
class User: Object {

    @objc enum UserType: Int {
        case normal
        case gold
        case premium
    }

    dynamic var type: UserType = .normal
    dynamic var name: String?
    dynamic var thumbnail: File?
    dynamic var isDeleted: Bool = false
    dynamic var itemIDs: Set<String> = []


    dynamic var item: Item?

    dynamic var files: [File] = []

    let followers: ReferenceCollection<User> = []
    let friends: ReferenceCollection<User> = []
    let items: NestedCollection<Item> = []
    let group: Reference<Group> = Reference()
    let media: ReferenceCollection<Media> = []

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
