//
//  ViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ViewController: UIViewController {

    @IBAction func buttonAction(_ sender: Any) {

    }

    var dataSource: DataSource<Item>?


    var users: [[String: Any]] = []

    let queue: DispatchQueue = DispatchQueue(label: "save.queue")

    var user: User?

    var item: Item?

    var d: DataSource<Item>?

    var tra: Transcript?

    override func viewDidLoad() {
        super.viewDidLoad()

        Transcript.get("khuRukcwO5a3IUL9Gimc") { (transcript, error) in
            print(transcript?.video?.file?.downloadURL)

            transcript?.video?.file = File(data: UIImagePNGRepresentation(User.image())!, mimeType: .png)
            transcript?.video?.file?.update({ (_, _) in
                transcript?.update()
            })

            self.tra = transcript
        }

//        let video: Video = Video()
//        video.file = File(data: UIImagePNGRepresentation(User.image())!, mimeType: .png)
//        let transcript: Transcript = Transcript()
////        transcript.file = File(data: UIImagePNGRepresentation(User.image())!, mimeType: .png)
//        transcript.video = video
//        let tasks = transcript.save()
//        print(tasks)
//        let user: User = User()
//        let item: Item = Item()
//        user.items.insert(item.id)
//        user.save()
//        let group: Group = Group()
//
//        (0..<10).forEach { (index) in
//            let item: Item = Item()
//            user.items.insert(item)
//        }
//        user.group = Reference(group)
//        user.save { (ref, _) in
//
//            let query: DataSource<Item>.Query = user.items.limit(to: 2)
//
//            debugPrint(query.query)
//
//            self.dataSource = query.dataSource().onCompleted({ (_, items) in
//                print(items)
//            }).get()
//
//        }
    }
}

