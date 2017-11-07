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
        let userA: User = User()
        userA.name = "userA"

        let userB: User = User()
        userB.name = "userB"

        let item: Item = Item()
        item.thumbnail = File(data: UIImageJPEGRepresentation(Item.image(), 0.3)!, mimeType: .jpeg)

        userA.referenceCollection.insert(userB)
        userA.nestedCollection.insert(item)
        userA.save()
    }

    var dataSource: DataSource<User>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let userA: User = User()
        userA.name = "userA"
        userA.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
        userA.save { (ref, error) in
            userA.thumbnail?.delete({ (error) in
                User.get(ref!.documentID, block: { (user, error) in
                    print(user)
                })
            })
        }
        

//        let userA: User = User()
//        userA.name = "userA"
//
//        let userB: User = User()
//        userB.name = "userB"
//
//        let item: Item = Item()
//        item.thumbnail = File(data: UIImageJPEGRepresentation(Item.image(), 0.3)!, mimeType: .jpeg)
//
//        userA.referenceCollection.insert(userB)
//        userA.nestedCollection.insert(item)
//        userA.save()


//        user.save { (ref, error) in
//            user.name = "B"
//            user.update { (error) in
//                User.get(ref!.documentID, block: { (aUser, error) in
//                    print(aUser)
//                })
//            }
//        }


//        let ref = Firestore.firestore().collection("test1").document("id")
//        ref.setData(["test": FieldValue.serverTimestamp(), "key": "hoge"]) { (error) in
//            let batch: WriteBatch = ref.firestore.batch()
//            batch.updateData(["test": FieldValue.serverTimestamp(), "key": "fuga"], forDocument: ref)
//            batch.commit(completion: { (error) in
//                ref.getDocument(completion: { (snapshot, error) in
//                    print("TEST 0", snapshot?.data()["test"], snapshot?.data()["key"])
//                })
//            })
//        }



//        self.dataSource = DataSource(reference: User.reference) { (change) in
//            print(change)
//        }

//        let db = Firestore.firestore().collection("test1").document("id")
//        db.setData(["test": FieldValue.serverTimestamp(), "key": "hoge"]) { (error) in
//            db.getDocument(completion: { (snapshot, error) in
//                print("TEST 0", snapshot?.data()["test"], snapshot?.data()["key"])
//                (0..<5).forEach({ index in
//                    let batch = db.firestore.batch()
//                    batch.updateData(["test": FieldValue.serverTimestamp(), "key": "\(index)"], forDocument: db)
//                    batch.commit(completion: { _ in
//                    })
//                })
//                db.getDocument(completion: { (snapshot, error) in
//                    print("TEST 1", snapshot?.data()["test"], snapshot?.data()["key"])
//                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
//                    db.getDocument(completion: { (snapshot, error) in
//                        print("TEST 2", snapshot?.data()["test"], snapshot?.data()["key"])
//                    })
//                })
//            })
//        }


    }
}

