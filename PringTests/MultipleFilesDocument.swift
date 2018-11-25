//
//  MultipleFilesObject.swift
//  PringTests
//
//  Created by 1amageek on 2017/11/07.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring
import Firebase
import FirebaseFirestore

@objcMembers
class MultipleFilesDocument: Object {

    dynamic var file0: File?
    dynamic var file1: File?
    dynamic var file2: File?

    dynamic var fileArray: [File] = []

    let files: NestedCollection<MultipleFilesNestedItem> = []

    let shallowFiles: NestedCollection<MultipleFilesShallowPathItem> = []

    let referenceShallowFile: Reference<MultipleFilesShallowPathItem> = .init()

    let relationShallowFile: Relation<MultipleFilesShallowPathItem> = .init()

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
