//
//  StorageLinkable.swift
//  Pring
//
//  Created by 1amageek on 2017/11/06.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public struct UploadContainer {

    static var queueLabel: String {
        return "Pring.upload.file.queue." + UUID().uuidString
    }

    let queue: DispatchQueue = DispatchQueue(label: queueLabel)

    let group: DispatchGroup = DispatchGroup()

    var tasks: [String: StorageUploadTask] = [:]

    var timeout: Int = 30 // Default 30s

    var error: Error? = nil {
        didSet {
            tasks.forEach({ (_, task) in
                task.cancel()
            })
        }
    }

    func wait(_ block: ((Error?) -> Void)?) {
        queue.async {
            self.group.notify(queue: DispatchQueue.main, execute: {
                block?(self.error)
            })
            switch self.group.wait(timeout: .now() + .seconds(self.timeout)) {
            case .success: break
            case .timedOut:
                self.tasks.forEach({ (_, task) in
                    task.cancel()
                })
                let error: DocumentError = DocumentError(kind: .timeout, description: "Save the file timeout.")
                DispatchQueue.main.async {
                    block?(error)
                }
            }
        }
    }
}

public struct DeleteContainer {

    static var queueLabel: String {
        return "Pring.delete.file.queue." + UUID().uuidString
    }

    let queue: DispatchQueue = DispatchQueue(label: queueLabel)

    let group: DispatchGroup = DispatchGroup()

    var timeout: Int = 30 // Default 30s

    var error: Error? = nil

    func wait(_ block: ((Error?) -> Void)?) {
        queue.async {
            self.group.notify(queue: DispatchQueue.main, execute: {
                block?(self.error)
            })
            switch self.group.wait(timeout: .now() + .seconds(self.timeout)) {
            case .success: break
            case .timedOut:
                let error: DocumentError = DocumentError(kind: .timeout, description: "Delete the file timeout.")
                DispatchQueue.main.async {
                    block?(error)
                }
            }
        }
    }
}

public protocol StorageLinkable {

    func shouldUploadFiles(_ id: String) -> Bool

    @discardableResult
    func saveFiles(container: UploadContainer?, block: ((Error?) -> Void)?) -> [String: StorageUploadTask]

    func deleteFiles(container: DeleteContainer?, block: ((Error?) -> Void)?)
}

extension StorageLinkable {

    public var timeout: Int { return 30 }
}
