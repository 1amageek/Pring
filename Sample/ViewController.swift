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
        let user: User = User()
        user.name = "aa"
        user.save()
    }

    var dataSource: DataSource<User>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = DataSource(reference: User.reference, block: { (change) in
            print(change)
        })
        

    }
}

