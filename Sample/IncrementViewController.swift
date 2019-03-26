//
//  IncrementViewController.swift
//  Sample
//
//  Created by 1amageek on 2019/03/21.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import UIKit
import Firebase

class IncrementViewController: UIViewController {


    @IBOutlet weak var label: UILabel!

    @IBAction func start(_ sender: Any) {
        let user: User = User(id: "hoge")
        (0..<30).forEach({ (index) in
            user.reference.setData(["followersCount": FieldValue.increment(1.0)], merge: true)
        })
    }

    @IBAction func startTransaction(_ sender: Any) {
        let user: User = User(id: "hoge")
        (0..<30).forEach({ (index) in
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                let snapshot: DocumentSnapshot = try! transaction.getDocument(user.reference)
                let count: Int = snapshot.data()!["followersCount"] as? Int ?? 0
                transaction.setData(["followersCount": count + 1], forDocument: user.reference, merge: true)
                return nil
            }, completion: { (_, _) in })
        })
    }

    var disposer: Disposer<User>?

    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        label.text = "0"
        label.sizeToFit()
        label.center = self.view.center
        self.view.addSubview(label)
        let uid: String = "hoge"
        self.listener = User(id: uid).reference.addSnapshotListener(includeMetadataChanges: true) { [weak self] (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {

                // ローカルのデータを反映する
                if !snapshot.metadata.isFromCache {
                    if let data: [String: Any] = snapshot.data() {
                        let count: Int = data["followersCount"] as! Int
                        self?.label.text = "\(count)"
                    }
                }

                // ローカルのデータは無視する
                if !snapshot.metadata.isFromCache && !snapshot.metadata.hasPendingWrites {
                    if let data: [String: Any] = snapshot.data() {
                        let count: Int = data["followersCount"] as! Int
                        self?.label.text = "\(count)"
                    }
                }
            }
        }
    }
}
