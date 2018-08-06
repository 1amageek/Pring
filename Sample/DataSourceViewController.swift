//
//  DataSourceViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/11/09.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import FirebaseStorage
import Pring

class DataSourceViewController: UITableViewController {

    var dataSource: DataSource<User>?

    @IBAction func add(_ sender: Any) {
        let user: User = User()
        user.name = UUID().uuidString
        user.save()
    }

    @IBAction func cancel(_ sender: Any) {
        if self.dataSource?.count ?? 0 > 0 {
            if let user: User = self.dataSource?[0] {
                user.delete()
            }
        }
    }

    @IBAction func next(_ sender: Any) {
        self.dataSource?.next()
    }
    
    var user: User?
    var item: Item?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let user: User = User()
//        let item: Item = Item()
//
//        user.itemIDs.insert(item.id)
//        user.items.insert(item)
//        user.save { (ref, error) in
//
//            let aUser: User = User(id: user.id, value: [:])
//            aUser.items.get(block: { (_, _) in
//                print("ITEM", aUser.items[0])
//            })
//        }

//        self.item = item
//        self.user = user

        let options: Options = Options()
        options.listeningChangeTypes = [.added, .modified]
        options.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: true)]
        self.dataSource = User.order(by: \User.updatedAt, descending: true).limit(to: 3).dataSource(options: options)
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
            })
            .on(parse: { (snapshot, user, done) in
                user.group.get({ (group, error) in
                    done(user)
                })
            })
            .onCompleted({ (snapshot, users) in
                debugPrint("completed")
            })
            .listen()
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
        cell.detailTextLabel?.text = user.group.object?.name
        cell.disposer = user.listen { (user, error) in
            guard let user = user else { return }
            cell.textLabel?.text = "\(user.createdAt)"
            cell.setNeedsLayout()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: DataSourceViewCell, forRowAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user: User = self.dataSource?[indexPath.item] else { return }
        let group: Group = Group()
        group.name = "update"
//        user.group.set(group)
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
