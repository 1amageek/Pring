//
//  MultipleFilesShallowPathItem.swift
//  PringTests
//
//  Created by 1amageek on 2018/03/13.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import Firebase
import FirebaseFirestore
import FirebaseStorage

@objcMembers
class MultipleFilesShallowPathItem: Object {

    dynamic var file: File?

    override var storageRef: StorageReference {
        return Storage.storage().reference().child(MultipleFilesShallowPathItem.path).child(self.id)
    }

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
