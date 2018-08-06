//
//  FileControlViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/12/28.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Pring

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
                    self.collectionView.reloadData()
                }
            })
            self.collectionView.reloadData()
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBAction func uploadAction(_ sender: Any) {
        let object: FileControlObject = FileControlObject()

        do {
            let file: File = File(data: UIImageJPEGRepresentation(FileControlObject.image(UIColor.blue), 0.2)!, mimeType: .jpeg)
            object.file = file
        }

        object.files = [UIColor.blue, UIColor.yellow, UIColor.red].map {
            return File(data: UIImageJPEGRepresentation(FileControlObject.image($0), 0.2)!, name: UUID().uuidString, mimeType: .jpeg)
        }

        object.save { _, error in
            print(object)
            print(error)
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

        object.files = [UIColor.purple, UIColor.brown, UIColor.orange].map {
            return File(data: UIImageJPEGRepresentation(FileControlObject.image($0), 0.2)!, name: UUID().uuidString, mimeType: .jpeg)
        }

        object.update(nil) { (error) in
            print(object)
            print(error)
        }
    }

    @IBAction func deleteAction(_ sender: Any) {
        guard let object: FileControlObject = self.object else {
            return
        }
        object.file = File.delete()
        object.files = []
        object.update()
    }

    @IBAction func deleteObjectAction(_ sender: Any) {
        guard let object: FileControlObject = self.object else {
            return
        }
        object.delete { (error) in
            self.collectionView.reloadData()
        }
    }

}

extension FileControlViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.object?.files.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        if let file: File = self.object?.files[indexPath.item] {
            if let url: URL = file.downloadURL {
                let data: Data = try! Data(contentsOf: url)
                let image: UIImage = UIImage(data: data)!
                let imageView: UIImageView = UIImageView(image: image)
                cell.backgroundView = imageView
                cell.backgroundView?.setNeedsDisplay()
            }
        }
        return cell
    }
}
