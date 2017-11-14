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

//        let user: User = User()
//        user.name = "Jony"
//        user.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
//        let task: [String: StorageUploadTask] = user.save()
//        task["thumbnail"]?.observe(.progress) { (snapshot) in
//            print(snapshot.progress?.completedUnitCount)
//        }

//        let collector: Collector = Collector()
//        let value: [String: Any] = collector.value as! [String: Any]
//        let reference = collector.reference
//        let batch: WriteBatch = Firestore.firestore().batch()
//        batch.setData(value, forDocument: reference)
//        batch.commit { (error) in
//            reference.getDocument(completion: { (snapshot, error) in
//                print(error)
//            })
//        }

        let item: Item = Item()
        self.user?.items.insert(item, block: { (error) in
            print(self.user?.items.count ,error)
        })
//        let user: User = User()
//        user.save { (_, error) in
//            self.user?.friends.insert(user, block: { (error) in
//                print(self.user?.friends.count ,error)
//            })
//        }

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

    var user: User?

    var item: Item?

    var d: DataSource<Item>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let c = Collector(id: "wn6jcN2kajmE8EuSGJrG")
//        self.d = c.referenceCollection.query.dataSource().onCompleted({ (_, items) in
//            print(items)
//        }).get()

//        self.d = c.nestedCollection.order(by: \Item.createdAt).dataSource().on({ (_, change) in
//            print(change)
//        }).onCompleted { (_, items) in
//            print(items)
//        }.get()

//        let c: Collector = Collector()
//
//        (0..<10).forEach { (index) in
//            let item = Item()
//            c.nestedCollection.insert(item)
//        }
//
//        c.save()

//        let user: User = User()
//        let value: [String: Any] = user.value as! [String: Any]
//        let reference = user.reference
//        let batch: WriteBatch = Firestore.firestore().batch()
//        batch.setData(value, forDocument: reference)
//        batch.commit { (error) in
//            reference.getDocument(completion: { (snapshot, error) in
//                print(error)
//            })
//        }



        let userA: User = User()
        userA.name = "userA"
//        userA.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
        userA.save { (ref, error) in
            self.user = userA
//            userA.thumbnail?.delete({ (error) in
//                User.get(ref!.documentID, block: { (user, error) in
//                    print(user)
//                })
//            })
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

