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
import Pring

class ViewController: UIViewController {

    @IBAction func buttonAction(_ sender: Any) {
        let group: Group = Group()
        let user: User = User()
        user.name = "hoge"
        user.group.set(group)
        user.item = Item()


        user.files.append(File(data: UIImageJPEGRepresentation(User.image(), 0.2)!, mimeType: .jpeg))
        user.files.append(File(data: UIImageJPEGRepresentation(User.image(), 0.2)!, mimeType: .jpeg))
        user.files.append(File(data: UIImageJPEGRepresentation(User.image(), 0.2)!, mimeType: .jpeg))
        user.files.append(File(data: UIImageJPEGRepresentation(User.image(), 0.2)!, mimeType: .jpeg)) 


        user.save()
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

//        Group.get("6MRhrD5IQd62xxrg84RI") { (group, error) in
//            User.reference.whereField("group", isEqualTo: group!.reference).getDocuments { (snapshot, error) in
//                print(snapshot?.documents.first)
//            }
//        }


//        let ref = Group(id: "6MRhrD5IQd62xxrg84RI").reference
//
//        User.where(\User.name, isEqualTo: "name").get { (snapshot, error) in
//            print(snapshot?.documents)
//        }
//
//        let user: User = User(id: "user_id")
//        user.items.where(\Item.name, isEqualTo: "item_name").get { (snapshot, error) in
//            print(snapshot?.documents)
//        }
//
//        user.items.where(\Item.name, isEqualTo: "item_name").dataSource()
//            .on({ (snapshot, change) in
//                // do something
//            })
//            .onCompleted { (snapshot, items) in
//            print(items)
//        }
//
//        User.where("group", isEqualTo: Group(id: "6MRhrD5IQd62xxrg84RI").reference).get { (snapshot, error) in
//            print(snapshot?.documents)
//        }

//        User.get("nnuqWHOddo640SPbyHXU") { (user, error) in
//            print(user)
//            print(user?.group.documentReference)
//        }
//
//        User.reference.document("nnuqWHOddo640SPbyHXU").getDocument { (snapshot, error) in
//            print(snapshot?.data())
//        }


//        User.get("Vveyas6yDJmmUJwBGCi6") { (user, error) in
//            user?.group.get({ (group, error) in
//                print(group)
//            })
//        }

//        let group: Group = Group()
//        let user: User = User()
//        user.group.set(group)
//        user.save()

//        Transcript.get("khuRukcwO5a3IUL9Gimc") { (transcript, error) in
//            print(transcript?.video?.file?.downloadURL)
//
//            transcript?.video?.file = File(data: UIImagePNGRepresentation(User.image())!, mimeType: .png)
//            transcript?.video?.file?.update({ (_, _) in
//                transcript?.update()
//            })
//
//            self.tra = transcript
//        }
//
//        let video: Video = Video()
//        video.file = File(data: UIImagePNGRepresentation(User.image())!, mimeType: .png)
//        let transcript: Transcript = Transcript()
//        transcript.video = video
//        transcript.save()
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

