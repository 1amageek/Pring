
//  File.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public final class File: NSObject {
    
    public enum MIMEType {
        case plain
        case csv
        case html
        case css
        case javascript
        case octetStream(String)
        case pdf
        case zip
        case tar
        case lzh
        case jpeg
        case pjpeg
        case png
        case gif
        case mp4
        case custom(String, String)

        var rawValue: String {
            switch self {
            case .plain:                 return "text/plain"
            case .csv:                   return "text/csv"
            case .html:                  return "text/html"
            case .css:                   return "text/css"
            case .javascript:            return "text/javascript"
            case .octetStream:           return "application/octet-stream"
            case .pdf:                   return "application/pdf"
            case .zip:                   return "application/zip"
            case .tar:                   return "application/x-tar"
            case .lzh:                   return "application/x-lzh"
            case .jpeg:                  return "image/jpeg"
            case .pjpeg:                 return "image/pjpeg"
            case .png:                   return "image/png"
            case .gif:                   return "image/gif"
            case .mp4:                   return "video/mp4"
            case .custom(let type, _):   return type
            }
        }

        var fileExtension: String {
            switch self {
            case .plain:                 return "txt"
            case .csv:                   return "csv"
            case .html:                  return "html"
            case .css:                   return "css"
            case .javascript:            return "js"
            case .octetStream(let ext):  return ext
            case .pdf:                   return "pdf"
            case .zip:                   return "zip"
            case .tar:                   return "tar"
            case .lzh:                   return "lzh"
            case .jpeg:                  return "jpg"
            case .pjpeg:                 return "jpg"
            case .png:                   return "png"
            case .gif:                   return "gif"
            case .mp4:                   return "mp4"
            case .custom(_, let ext):    return ext
            }
        }

        init?(rawValue: String, ext: String? = nil) {
            switch rawValue {
            case "text/plain":                  self = .plain
            case "text/csv":                    self = .csv
            case "text/html":                   self = .html
            case "text/css":                    self = .css
            case "text/javascript":             self = .javascript
            case "application/octet-stream":    self = .octetStream(ext ?? "")
            case "application/pdf":             self = .pdf
            case "application/zip":             self = .zip
            case "application/x-tar":           self = .tar
            case "application/x-lzh":           self = .lzh
            case "image/jpeg":                  self = .jpeg
            case "image/pjpeg":                 self = .pjpeg
            case "image/png":                   self = .png
            case "image/gif":                   self = .gif
            case "video/mp4":                   self = .mp4
            default:                            self = .custom(rawValue, ext ?? "")
            }
        }
    }

    /// Save location
    public var ref: StorageReference? {
        if let parent: Object = self.parent, let key: String = self.key {
            return parent.storageRef.child(key).child(self.name)
        }
        return nil
    }

    /// ConentType
    public var mimeType: MIMEType?

    /// Save data
    public var data: Data?

    /// Save URL
    public var url: URL?

    /// File name
    public var name: String

    /// File metadata
    public var metadata: StorageMetadata?

    ///
    public var additionalData: [String: Any]?

    /// File is saved
    public var isSaved: Bool {
        return self.downloadURL != nil
    }

    public var isDeleted: Bool = false

    public var shouldBeSaved: Bool {
        return !self.isSaved && !self.deleteRequest
    }

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    /// DownloadURL
    public var downloadURL: URL? {
        return _downloadURL
    }

    /// private downloadURL
    private var _downloadURL: URL?

    /// has extension
    private var hasExtension: Bool = true

    /// File detail value
    public var value: [String: Any] {
        var value: [String: Any] = ["name": self.name]
        if let downloadURL: URL = self.downloadURL {
            value["url"] = downloadURL.absoluteString
        }
        if let mimeType: String = self.mimeType?.rawValue {
            value["mimeType"] = mimeType
        }
        if let additionalData: [String: Any] = self.additionalData {
            value["additionalData"] = additionalData
        }
        return value
    }

    internal var deleteRequest: Bool = false

    /// Firebase uploading task
    public fileprivate(set) weak var uploadTask: StorageUploadTask?

    /// Firebase downloading task
    public fileprivate(set) weak var downloadTask: StorageDownloadTask?

    public class func delete() -> File {
        let file: File = File(name: "")
        file.deleteRequest = true
        return file
    }

    // MARK: - Initialize

    public init(name: String) {
        self.name = name
    }

    public convenience init(data: Data,
                            name: String? = nil,
                            mimeType: MIMEType? = nil) {
        let fileName: String = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        self.init(name: fileName)
        self.mimeType = mimeType
        self.data = data
    }

    public convenience init(url: URL,
                            name: String? = nil,
                            mimeType: MIMEType? = nil) {
        let fileName: String = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        self.init(name: fileName)
        self.mimeType = mimeType
        self.url = url
    }

    internal convenience init?(property: [String: Any]) {
        guard let name: String = property["name"] as? String else { return nil }
        self.init(name: name)
        if let mimeType: String = property["mimeType"] as? String {
            self.mimeType = MIMEType(rawValue: mimeType)
        }
        if let downloadURL: String = property["url"] as? String {
            self._downloadURL = URL(string: downloadURL)
        }
        if let additionalData: [String: Any] = property["additionalData"] as? [String: Any] {
            self.additionalData = additionalData
        }
    }

    internal func setParent(_ object: Object, forKey key: String) {
        self.parent = object
        self.key = key
    }

    class func generateFileName(_ name: String, mimeType: MIMEType?) -> String {
        var fileName: String = name
        if let mimeType: MIMEType = mimeType {
            let url: URL = URL(string: name)!
            fileName = url.pathExtension.isEmpty ? url.appendingPathExtension(mimeType.fileExtension).absoluteString : name
        }
        return fileName
    }

    // MARK: - SAVE

    internal func save(_ key: String) -> StorageUploadTask? {
        return self.save(key, completion: nil)
    }

    internal func save(_ key: String, completion: ((StorageMetadata?, Error?) -> Void)?) -> StorageUploadTask? {

        guard let reference: StorageReference = self.ref else {
            let error: DocumentError = DocumentError(kind: .invalidFile, description: "There is no save destination for this file.")
            completion?(nil, error)
            return nil
        }

        let metadata: StorageMetadata = StorageMetadata()
        if let mimeType: MIMEType = self.mimeType {
            metadata.contentType = mimeType.rawValue
        }

        if let data: Data = self.data {
            self.uploadTask = reference.putData(data, metadata: metadata) { (metadata, error) in
                self.metadata = metadata
                if let error = error {
                    completion?(metadata, error)
                    return
                }
                reference.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion?(metadata, error)
                        return
                    }
                    self._downloadURL = url
                    completion?(metadata, error)
                })
            }
            return self.uploadTask
        } else if let url: URL = self.url {
            self.uploadTask = reference.putFile(from: url, metadata: metadata, completion: { (metadata, error) in
                self.metadata = metadata
                if let error = error {
                    completion?(metadata, error)
                    return
                }
                reference.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion?(metadata, error)
                        return
                    }
                    self._downloadURL = url
                    completion?(metadata, error)
                })
            })
            return self.uploadTask
        } else {
            let error: DocumentError = DocumentError(kind: .invalidFile, description: "It requires data when you save the file")
            completion?(nil, error)
        }
        return nil
    }

    // MARK: - DELETE

    internal func delete(_ block: ((Error?) -> Void)? = nil) {
        guard let parent: Object = self.parent, let key: String = self.key else {
            fatalError("[Pring.Document] *** error: The necessary elements for deleting the file are insufficient.")
        }
        self.ref?.delete(completion: { (error) in
            if let error: Error = error {
                block?(error)
                return
            }
            parent.update(key: key, value: FieldValue.delete())
            self.isDeleted = false
            block?(nil)
        })
    }

    // MARK: - RETRIEVE

    /// Default 100MB
    public func getData(_ size: Int64 = Int64(10e8), completion: @escaping (Data?, Error?) -> Void) -> StorageDownloadTask? {
        self.downloadTask?.cancel()
        let task: StorageDownloadTask? = self.ref?.getData(maxSize: size, completion: { (data, error) in
            self.downloadTask = nil
            completion(data, error as Error?)
        })
        self.downloadTask = task
        return task
    }

    deinit {
        self.parent = nil
    }

    // MARK: -

    override public var description: String {
        let base: String =
            "      name: \(self.name)\n" +
            "      url: \(self.url?.absoluteString ?? "")\n" +
            "      donwloadURL: \(self.downloadURL?.absoluteString ?? "")\n" +
            "      hasParent: \(self.parent != nil ? "true" : "false")\n" +
            "      key: \(self.key ?? "")\n" +
            "    "
        return "\n    File {\n\(base)}"
    }
}

extension Array where Element: File {

    internal func _dispose(_ block: @escaping ([Error]) -> Void) {
        let queue: DispatchQueue = DispatchQueue(label: "Pring.File.disposal.queue")
        let group: DispatchGroup = DispatchGroup()
        queue.async {
            var errors: [Error] = []
            self.forEach { (file) in
                group.enter()
                file.ref?.delete(completion: { (error) in
                    defer {
                        group.leave()
                    }
                    if let error = error {
                        errors.append(error)
                    }
                })
            }
            group.notify(queue: DispatchQueue.main, execute: {
                block(errors)
            })
            switch group.wait(timeout: .now() + .seconds(30)) {
            case .success: break
            case .timedOut:
                let error: DocumentError = DocumentError(kind: .timeout, description: "File deletion processing timed out.")
                errors.append(error)
                DispatchQueue.main.async {
                    block(errors)
                }
            }
        }

    }
}
