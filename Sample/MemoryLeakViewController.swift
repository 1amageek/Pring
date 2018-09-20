//
//  MemoryLeakViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/09/20.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring

func unwrap(_ value: Any) -> Any? {
    let mirror = Mirror(reflecting: value)
    if let (label, v) = mirror.children.first {
        if label == "some" {
            return v
        }
        return value
    }
    return nil
}

@objcMembers
class Prop: NSObject {
    weak var parent: Doc?
}

@objcMembers
class Doc: Object {

    dynamic var prop: Prop = Prop()


//    let pp: Prop = .init()

//    let refItem: Reference<User> = .init()

    var avalue: [String: Any?] {
        let mirror = Mirror(reflecting: self)
        var document: [String: Any] = [:]
        mirror.children.forEach { (key, value) in
            print(key, value)
            if let key: String = key {
                document[key] = value
            }
        }
        return document
    }
}

class MemoryLeakViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            weak var weakObject: Doc?
            weak var weakProp: Prop?
            do {
                let object: Doc = Doc()
//                let prop: Prop = Prop()
////                object.pp.parent = object
////                object.refItem.parent = object
//                object.prop = prop
                object.prop.parent = object
//                weakProp = prop
                weakObject = object

                print(object.avalue)
                CFGetRetainCount(object)
                CFGetRetainCount(weakObject)
//                CFGetRetainCount(prop)
            }
            print(weakObject)
            print(weakProp)
        }

    }

}
