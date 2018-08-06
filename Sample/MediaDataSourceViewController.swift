//
//  MediaDataSourceViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/03/06.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring

private let reuseIdentifier = "Cell"

class MediaDataSourceViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBAction func addMedia(_ sender: Any) {
        let media: Media = Media()
        media.name = "\(self.count)"
        self.count += 1
        self.user?.media.insert(media)
        self.user?.update()
    }

    var dataSource: DataSource<Media>?

    var user: User?

    var count: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(MediaDataSourceViewCell.self, forCellWithReuseIdentifier: "MediaDataSourceViewCell")
        let user: User = User(id: "HMdIc8QFLtBHC2HBa9U9", value: [:])
        self.user = user
//        user.save { (_, _) in

        let options: Options = Options()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        options.sortDescriptors = [sortDescriptor]
            self.dataSource = user
                .media
                .order(by: "createdAt")
                .dataSource(options: options).on({ [weak self] (_, changes) in
                    guard let collectionView: UICollectionView = self?.collectionView else { return }
                    switch changes {
                    case .initial:
                        collectionView.reloadData()
                    case .update(let deletions, let insertions, let modifications):
                        collectionView.performBatchUpdates({
                            collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                            collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                            collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                        }, completion: nil)
                    case .error(let error):
                        debugPrint(error)
                    }
                }).listen()
//        }


    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaDataSourceViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaDataSourceViewCell", for: indexPath) as! MediaDataSourceViewCell
        if let media: Media = self.dataSource?[indexPath.item] {
            cell.text = media.name
        }
        cell.backgroundColor = .white
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
}
