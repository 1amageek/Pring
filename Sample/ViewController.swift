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

    var dataSource: DataSource<User>?


    var users: [[String: Any]] = []

    let queue: DispatchQueue = DispatchQueue(label: "save.queue")

    var user: User?

    var item: Item?

    var d: DataSource<Item>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let group: Group = Group()

        let user: User = User()
        user.name = "aaaa"

        group.owner = Reference(user)

        group.save()

//        let user: User = User()
//
//        user.name = "media"
//
//        let photo: Photo = Photo()
//
//        user.content = Media(photo)


//        let userA: User = User()
//        let userB: User = User()
//
//        userA.name = "userA"
//        userB.name = "userB"
//
//        userA.save { _, _ in
//            userB.save({ _, _ in
//                userA.name = "USER A"
//                userB.name = "USER B"
//                let batch = userA.pack(.update)
//                batch.add(.update, object: userB)
//                batch.commit(completion: { (error) in
//                    print(error)
//                })
//            })
//        }
    }
}

