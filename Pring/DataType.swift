//
//  DataType.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum DataType {
    /**
     | key | Firestore | Local |
    */
    case array      (String, [Any], [Any])
    case set        (String, [AnyHashable: Bool], Set<String>)
    case bool       (String, Bool, Bool)
    case binary     (String, Data, Data)           // Up to 1,048,487 bytes
    case file       (String, [AnyHashable: Any], File)
    case url        (String, String, URL)
    case int        (String, Int, Int)
    case float      (String, Double, Double)
    case date       (String, Date, Date)
    case geoPoint   (String, GeoPoint, GeoPoint)
    case dictionary (String, [AnyHashable: Any], [AnyHashable: Any])
    case relation   (String, [AnyHashable: Any], ReferenceCollection)
    case string     (String, String, String)
    case null

    /**
     Encode to firestore data type

     | key | Firestore | Local |
    */
    public init(key: String, value: Any) {
        switch value.self {
        case is Bool:
            if let value: Bool = value as? Bool {
                self = .bool(key, value, value)
                return
            }
        case is Int:
            if let value: Int = value as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        case is Int8:
            if let value: Int8 = value as? Int8 {
                self = .int(key, Int(value), Int(value))
                return
            }
        case is Int16:
            if let value: Int16 = value as? Int16 {
                self = .int(key, Int(value), Int(value))
                return
            }
        case is Int32:
            if let value: Int32 = value as? Int32 {
                self = .int(key, Int(value), Int(value))
                return
            }
        case is Int64:
            if let value: Int64 = value as? Int64 {
                self = .int(key, Int(value), Int(value))
                return
            }
        case is UInt: fatalError("UInt is not supported.")
        case is Float, is Double:
            if let value: Double = value as? Double {
                self = .float(key, Double(value), Double(value))
                return
            }
        case is String:
            if let value: String = value as? String {
                self = .string(key, value, value)
                return
            }
        case is URL:
            if let value: URL = value as? URL {
                self = .url(key, value.absoluteString, value)
                return
            }
        case is Date:
            if let value: Date = value as? Date {
                self = .date(key, value, value)
                return
            }
        case is GeoPoint:
            if let value: GeoPoint = value as? GeoPoint {
                self = .geoPoint(key, value, value)
                return
            }
        case is [Any]:
            if let value: [Any] = value as? [Any], !value.isEmpty {
                self = .array(key, value, value)
                return
            }
        case is Set<String>:
            if let value: Set<String> = value as? Set<String>, !value.isEmpty {
                self = .set(key, value.toKeys(), value)
                return
            }
        case is File:
            if let value: File = value as? File {
                self = .file(key, value.value, value)
                return
            }
        case is ReferenceCollection:
            if let value: ReferenceCollection = value as? ReferenceCollection {
                self = .relation(key, value.value, value)
                return
            }
        case is [String: Any]:
            if let value: [String: Any] = value as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        case is [AnyHashable: Any]:
            if let value: [String: Any] = value as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        default:
            self = .null
            //print("[Pring.Base] This property(\(key) is null", value, String(describing: type(of: value)))
            return
        }
        self = .null
    }

    /**
     Decode to local data type
     */
    public init(key: String, value: Any, data: [String: Any]) {
        let mirror: Mirror = Mirror(reflecting: value)
        let subjectType: Any.Type = mirror.subjectType
        if subjectType == Bool.self || subjectType == Bool?.self {
            if let value: Bool = data[key] as? Bool {
                self = .bool(key, Bool(value), Bool(value))
                return
            }
        } else if subjectType == Int.self || subjectType == Int?.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int8.self || subjectType == Int8?.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int16.self || subjectType == Int16?.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int32.self || subjectType == Int32?.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int64.self || subjectType == Int64?.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Float.self || subjectType == Float?.self {
            if let value: Float = data[key] as? Float {
                self = .float(key, Double(value), Double(value))
                return
            }
        } else if subjectType == Double.self || subjectType == Double?.self {
            if let value: Double = data[key] as? Double {
                self = .float(key, Double(value), Double(value))
                return
            }
        } else if subjectType == String.self || subjectType == String?.self {
            if let value: String = data[key] as? String {
                self = .string(key, value, value)
                return
            }
        } else if subjectType == URL.self || subjectType == URL?.self {
            if
                let value: String = data[key] as? String,
                let url: URL = URL(string: value)  {
                self = .url(key, value, url)
                return
            }
        } else if subjectType == Date.self || subjectType == Date?.self {
            if let value: Date = data[key] as? Date {
                self = .date(key, value, value)
                return
            }
        } else if subjectType == [Int].self || subjectType == [Int]?.self {
            if let value: [Int] = data[key] as? [Int], !value.isEmpty {
                self = .array(key, value, value)
                return
            }
        } else if subjectType == [String].self || subjectType == [String]?.self {
            if let value: [String] = data[key] as? [String], !value.isEmpty {
                self = .array(key, value, value)
                return
            }
        } else if subjectType == [Any].self || subjectType == [Any]?.self {
            if let value: [Any] = data[key] as? [Any], !value.isEmpty {
                self = .array(key, value, value)
                return
            }
        } else if subjectType == Set<String>.self || subjectType == Set<String>?.self {
            if let value: [String: Bool] = data[key] as? [String: Bool], !value.isEmpty {
                self = .set(key, value, Set<String>(value.keys))
                return
            }
            if let value: [Int: Bool] = data[key] as? [Int: Bool], !value.isEmpty {
                let value: [String: Bool] = value.reduce([String: Bool](), { (result, obj) -> [String: Bool] in
                    var result = result
                    result[String(obj.key)] = obj.value
                    return result
                })
                self = .set(key, value, Set<String>(value.keys))
                return
            }
            if let value: [Bool] = data[key] as? [Bool], !value.isEmpty {
                var result: [String: Bool] = [:]
                for (i, v) in value.enumerated() {
                    result[String(i)] = v
                }
                self = .set(key, result, Set<String>(result.keys))
                return
            }
        } else if subjectType == [String: Any].self || subjectType == [String: Any]?.self {
            if let value: [String: Any] = data[key] as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        } else if subjectType == [AnyHashable: Any].self || subjectType == [AnyHashable: Any]?.self {
            if let value: [String: Any] = data[key] as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        } else if subjectType == File.self || subjectType == File?.self {
            if let value: [AnyHashable: String] = data[key] as? [AnyHashable: String] {
                if let file: File = File(propery: value) {
                    self = .file(key, value, file)
                    return
                }
            }
        } else if value is ReferenceCollection {
            let relation: ReferenceCollection = value as! ReferenceCollection
            if let value: [AnyHashable: Any] = data[key] as? [AnyHashable: Any] {
                self = .relation(key, value, relation)
                return
            }
        } else {
            self = .null
        }
        self = .null
    }
}

extension Collection where Iterator.Element == String {
    func toKeys() -> [String: Bool] {
        return reduce(into: [:]) { $0[$1] = true }
    }
}
