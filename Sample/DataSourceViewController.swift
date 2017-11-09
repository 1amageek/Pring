//
//  DataSourceViewController.swift
//  Sample
//
//  Created by 1amageek on 2017/11/09.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

class DataSourceViewController: UITableViewController {

    var dataSource: DataSource<User>?

    @IBAction func add(_ sender: Any) {
        let user: User = User()
        user.name = UUID().uuidString
        user.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = User.order(by: \User.createdAt).limit(to: 30).dataSource()
            .on({ (snapshot, changes) in
                guard let tableView: UITableView = self.tableView else { return }
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
            self.dataSource?.removeObject(at: indexPath.item, block: { (key, error) in
                
            })
        }
    }
}
