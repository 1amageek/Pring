//
//  DataSourceViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/11/09.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseStorage

class DataSourceViewController: UITableViewController {

    var dataSource: DataSource<User>?

    @IBAction func add(_ sender: Any) {
        let user: User = User()
        user.name = UUID().uuidString
        (0..<10).forEach { (index) in
            let aUser: User = User()
            aUser.name = "\(index)"
            user.followers.insert(aUser)
        }
        user.save()
//        user.thumbnail = File(data: UIImageJPEGRepresentation(User.image(), 0.3)!, mimeType: .jpeg)
//        let task: [String: StorageUploadTask] = user.save()
//        task["thumbnail"]?.observe(.progress) { (snapshot) in
//            print(snapshot.progress?.completedUnitCount)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        User.get("A5TshfykKf1XXVqIaDio") { (user, error) in
            guard let user: User = user else { return }
            self.dataSource = user.followers.order(by: \User.createdAt).dataSource()
                .on({ [weak self] (snapshot, changes) in
                guard let tableView: UITableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.endUpdates()
                case .error(let error):
                    print(error)
                }
            }).listen()
        }

//        self.dataSource = User.order(by: \User.createdAt).limit(to: 30).dataSource()
//            .on({ [weak self] (snapshot, changes) in
//                guard let tableView: UITableView = self?.tableView else { return }
//                switch changes {
//                case .initial:
//                    tableView.reloadData()
//                case .update(let deletions, let insertions, let modifications):
//                    tableView.beginUpdates()
//                    tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                    tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                    tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                    tableView.endUpdates()
//                case .error(let error):
//                    print(error)
//                }
//            }).listen()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DataSourceViewCell = tableView.dequeueReusableCell(withIdentifier: "DataSourceViewCell", for: indexPath) as! DataSourceViewCell
        configure(cell, atIndexPath: indexPath)
        return cell
    }

    func configure(_ cell: DataSourceViewCell, atIndexPath indexPath: IndexPath) {
        guard let user: User = self.dataSource?[indexPath.item] else { return }
        cell.textLabel?.text = user.name
        cell.disposer = user.listen { (user, error) in
            cell.textLabel?.text = user?.name
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: DataSourceViewCell, forRowAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataSource?.removeDocument(at: indexPath.item, block: { (key, error) in
                print(error)
            })
        }
    }
}
