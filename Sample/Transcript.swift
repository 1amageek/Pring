//
//  Transcript.swift
//  Sample
//
//  Created by 1amageek on 2017/12/13.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Pring

@objcMembers
class Transcript: Object {

    dynamic var text: String?
    dynamic var video: Video?
    dynamic var file: File?

    override func encode(_ key: String, value: Any?) -> Any? {
        switch key {
        case "video":
            return self.video?.value
        default: return nil
        }
    }

    override func decode(_ key: String, value: Any?) -> Bool {
        switch key {
        case "video":
            self.video = Video(id: key, value: value as! [AnyHashable : Any])
            return true
        default: return false
        }
    }

}
