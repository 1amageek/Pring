
//  File.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

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
            return Storage.storage().reference().child(parent.path).child(key).child(self.name)
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

    /// Parent to hold the location where you want to save
    public weak var parent: Object?

    /// Property name to save
    public var key: String?

    /// DownloadURL
    public var downloadURL: URL? {
        if let url: URL = self._downloadURL {
            return url
        }
        return self.metadata?.downloadURL()
    }

    /// private downloadURL
    private var _downloadURL: URL?

    /// has extension
    private var hasExtension: Bool = true

    /// File detail value
    public var value: [AnyHashable: Any] {
        var value: [AnyHashable: Any] = ["name": self.name]
        if let downloadURL: URL = self.downloadURL {
            value["url"] = downloadURL.absoluteString
        }
        if let mimeType: String = self.mimeType?.rawValue {
            value["mimeType"] = mimeType
        }
        return value
    }

    /// Firebase uploading task
    public fileprivate(set) weak var uploadTask: StorageUploadTask?

    /// Firebase downloading task
    public fileprivate(set) weak var downloadTask: StorageDownloadTask?

    internal var garbage: StorageReference?

    // MARK: - Initialize

    public init(name: String) {
        self.name = name
    }

    public convenience init(name: String? = nil,
                            data: Data,
                            mimeType: MIMEType? = nil) {
        let fileName: String = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        self.init(name: fileName)
        self.mimeType = mimeType
        self.data = data
    }

    public convenience init(name: String? = nil,
                            url: URL,
                            mimeType: MIMEType? = nil) {
        let fileName: String = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        self.init(name: fileName)
        self.mimeType = mimeType
        self.url = url
    }

    internal convenience init?(propery: [AnyHashable: String]) {
        guard let name: String = propery["name"] else { return nil }
        self.init(name: name)
        if let mimeType: String = propery["mimeType"] {
            self.mimeType = MIMEType(rawValue: mimeType)
        }
        if let downloadURL: String = propery["url"] {
            self._downloadURL = URL(string: downloadURL)
        }
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

        let metadata: StorageMetadata = StorageMetadata()
        if let mimeType: MIMEType = self.mimeType {
            metadata.contentType = mimeType.rawValue
        }

        if let data: Data = self.data {
            let parent: Object? = self.parent
            self.uploadTask = self.ref?.putData(data, metadata: metadata) { (metadata, error) in
                self.metadata = metadata
                if let error: Error = error as Error? {
                    completion?(metadata, error)
                    return
                }
                if let parent: Object = parent, parent.isListening {
                    parent.update(key: key, value: self.value)
                    parent.update { (error) in
                        completion?(metadata, error)
                    }
                } else {
                    completion?(metadata, error)
                }
            }
            return self.uploadTask
        } else if let url: URL = self.url {
            let parent: Object? = self.parent
            self.uploadTask = self.ref?.putFile(from: url, metadata: metadata, completion: { (metadata, error) in
                self.metadata = metadata
                if let error: Error = error as Error? {
                    completion?(metadata, error)
                    return
                }
                if let parent: Object = parent, parent.isListening {
                    parent.update(key: key, value: self.value)
                    parent.update { (error) in
                        completion?(metadata, error)
                    }
                } else {
                    completion?(metadata, error)
                }
            })
            return self.uploadTask
        } else {
            let error: DocumentError = DocumentError(kind: .invalidFile, description: "It requires data when you save the file")
            completion?(nil, error)
        }
        return nil
    }

    // MARK: - UPDATE

    @discardableResult
    public func update(_ block: ((StorageMetadata?, Error?) -> Void)?) -> StorageUploadTask? {
        guard let _: Object = self.parent, let key: String = self.key else {
            let error: DocumentError = DocumentError(kind: .invalidFile, description: "It requires data when you save the file")
            block?(nil, error)
            return nil
        }

        return self.save(key, completion: { (metadata, error) in
            if let error = error {
                block?(nil, error)
                return
            }
            if let ref: StorageReference = self.garbage {
                ref.delete(completion: { (error) in
                    block?(metadata, error)
                })
            } else {
                block?(metadata, error)
            }
        })
    }

    // MARK: - DELETE

    public func delete(_ block: ((Error?) -> Void)? = nil) {
        guard let parent: Object = self.parent, let key: String = self.key else {
            fatalError("[Pring.Document] *** error: The necessary elements for deleting the file are insufficient.")
        }
        self.ref?.delete(completion: { (error) in
            parent.update(key: key, value: FieldValue.delete())
            parent.update { error in
                parent[key] = nil
                block?(error)
            }
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
            "      hasParent: \(self.parent != nil ? "true" : "false")\n" +
            "      key: \(self.key ?? "")\n" +
            "    "
        return "\n    File {\n\(base)}"
    }
}
