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

        let user: User = User()
        user.name = "Jony"
        user.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
        let task: [String: StorageUploadTask] = user.save()
        task["thumbnail"]?.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount)
        }
        
    }

    var dataSource: DataSource<User>?



//    var users: [User] = []

//    func get() {
//        User.query.get { (snapshot, error) in
//            snapshot?.documentChanges.forEach({ (change) in
//                let id: String = change.document.documentID
//                User.get(id, block: { (document, error) in
//                    guard let document: User = document else { return }
//                    print(document)
//                    self.users.append(document)
//                })
//            })
//        }
//    }

    var users: [[String: Any]] = []

    let queue: DispatchQueue = DispatchQueue(label: "save.queue")

    override func viewDidLoad() {
        super.viewDidLoad()

        let reference: CollectionReference = User.reference

        (0..<30).forEach { (index) in
//            let batch: WriteBatch = Firestore.firestore().batch()
//            let user = reference.document()
//            batch.setData([
//                "createdAt": Date(),
//                "updatedAt": Date(),
//                "name": "\(index)"
//                ], forDocument: user)
//            batch.commit(completion: { (error) in
//                user.getDocument(completion: { (snapshot, error) in
//                    print(error)
//                })
//            })

            let user: User = User()
            user.name = "\(index)"
            user.save()
        }

//        let userA: User = User()
//        userA.name = "userA"
//        userA.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
//        userA.save { (ref, error) in
//            userA.thumbnail?.delete({ (error) in
//                User.get(ref!.documentID, block: { (user, error) in
//                    print(user)
//                })
//            })
//        }


//        let userA: User = User()
//        userA.name = "userA"
//
//        let userB: User = User()
//        userB.name = "userB"
//
//        let item: Item = Item()
//        item.thumbnail = File(data: UIImageJPEGRepresentation(Item.image(), 0.3)!, mimeType: .jpeg)
//
//        userA.followers.insert(userB)
//        userA.items.insert(item)
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

