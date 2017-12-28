//
//  FileControlViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/12/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore

@objcMembers
class FileControlObject: Object {

    dynamic var file: File?
    dynamic var files: [File] = []

    static func image(_ color: UIColor) -> UIImage {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(frame)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

class FileControlViewController: UIViewController {

    var listener: ListenerRegistration?

    var object: FileControlObject? {
        didSet {
            if let url: URL = object?.file?.downloadURL {
                let data: Data = try! Data(contentsOf: url)
                let image: UIImage = UIImage(data: data)!
                self.imageView.image = image
                self.imageView.setNeedsDisplay()
            }
            self.listener = object?.listen({ (object, error) in
                if let url: URL = object?.file?.downloadURL {
                    let data: Data = try! Data(contentsOf: url)
                    let image: UIImage = UIImage(data: data)!
                    self.imageView.image = image
                    self.imageView.setNeedsDisplay()
                }
            })
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func uploadAction(_ sender: Any) {
        let object: FileControlObject = FileControlObject()

        do {
            let file: File = File(data: UIImageJPEGRepresentation(FileControlObject.image(UIColor.blue), 0.2)!, mimeType: .jpeg)
            object.file = file
        }

        object.save { _, _ in
            self.object = object
        }
    }

    @IBAction func updateAction(_ sender: Any) {
        guard let object: FileControlObject = self.object else {
            return
        }

        do {
            let file: File = File(data: UIImageJPEGRepresentation(FileControlObject.image(UIColor.green), 0.2)!, mimeType: .jpeg)
            object.file = file
        }

        object.update()
    }

    @IBAction func deleteAction(_ sender: Any) {

    }

}
