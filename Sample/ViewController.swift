//
//  ViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {

    @IBAction func buttonAction(_ sender: Any) {
        self.user?.name = "userB"
    }

    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

//        do {
//            let db = Firestore.firestore().collection("test0").document("id")
//            db.setData(["test": FieldValue.serverTimestamp(), "key": "hoge"]) { (error) in
//                db.getDocument(completion: { (snapshot, error) in
//                    db.updateData(["test": FieldValue.serverTimestamp(), "key": "fuga"], completion: { (error) in
//                        db.getDocument(completion: { (snapshot, error) in
//                            print("TEST 0", snapshot?.data()["test"])
//                        })
//                    })
//                })
//            }
//        }

        do {
            let db = Firestore.firestore().collection("test1").document("id")
            db.setData(["test": FieldValue.serverTimestamp(), "key": "hoge"]) { (error) in
                db.getDocument(completion: { (snapshot, error) in
                    print("TEST 0", snapshot?.data()["test"])
                    (0..<5).forEach({ index in
                        db.updateData(["test": FieldValue.serverTimestamp(), "key": "\(index)"], completion: nil)
//                        let batch = db.firestore.batch()
//                        batch.updateData(["test": FieldValue.serverTimestamp(), "key": "\(index)"], forDocument: db)
//                        batch.commit(completion: { _ in
//                        })
                    })
                    db.getDocument(completion: { (snapshot, error) in
                        print("TEST 1", snapshot?.data()["test"])
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                        db.getDocument(completion: { (snapshot, error) in
                            print("TEST 2", snapshot?.data()["test"])
                        })
                    })
                })
            }
        }


//        let userA: User = User()
//        userA.name = "userA"
////        userA.thumbnailImage = File(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "pring_logo"))!, mimeType: .png)
//        self.user = userA
//        userA.save { (ref, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            userA.name = "userD"
//
////            let userB: User = User()
////            userB.name = "userB"
////            userB.thumbnailImage = File(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "pring_logo"))!, mimeType: .png)
////            userA.followers.insert(userB)
//
////            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
////                userA.name = "userC"
////                userB.name = "userD"
////            })
//
//        }

    }
}

