//
//  Item.swift
//  Sample
//
//  Created by 1amageek on 2017/10/27.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring

@objcMembers
class Item: Object {
    dynamic var thumbnail: File?
    dynamic var name: String? = "OWABIISHI"

    static func image() -> UIImage {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(frame)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
