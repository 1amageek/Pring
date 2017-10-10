//
//  ViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/10/10.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let userA: User = User()
        userA.name = "userA"
        userA.thumbnailImage = File(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "pring_logo"))!, mimeType: .png)
        userA.save { (ref, error) in
            if let error = error {
                print(error)
                return
            }

            let userB: User = User()
            userB.name = "userB"
            userB.thumbnailImage = File(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "pring_logo"))!, mimeType: .png)
            userA.followers.insert(userB)

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                userA.name = "userC"
//                userB.name = "userD"
//            })

        }
    }
}

