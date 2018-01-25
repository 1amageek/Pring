//
//  DataType.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

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
    case files      (String, [[AnyHashable: String]], [File])
    case url        (String, String, URL)
    case int        (String, Int, Int)
    case float      (String, Double, Double)
    case date       (String, Date, Date)
    case geoPoint   (String, GeoPoint, GeoPoint)
    case dictionary (String, [AnyHashable: Any], [AnyHashable: Any])
    case collection (String, [AnyHashable: Any], AnySubCollection)
    case reference  (String, DocumentReference?, AnyReference)
    case string     (String, String, String)
    case document   (String, [AnyHashable: Any], Object?)
    case null

    /**
     Encode to firestore data type

     | key | Firestore | Local |
    */
    public init(key: String, value: Any?) {
        guard let value = value else {
            self = .null
            return
        }

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
        case is Data:
            if let value: Data = value as? Data {
                self = .binary(key, value, value)
                return
            }
        case is GeoPoint:
            if let value: GeoPoint = value as? GeoPoint {
                self = .geoPoint(key, value, value)
                return
            }
        case is [File]:
            if let value: [File] = value as? [File] {
                self = .files(key, value.map { return $0.value as! [AnyHashable: String] }, value)
                return
            }
        case is [Any]:
            if let value: [Any] = value as? [Any] {
                self = .array(key, value, value)
                return
            }
        case is Set<String>:
            if let value: Set<String> = value as? Set<String> {
                self = .set(key, value.toKeys(), value)
                return
            }
        case is File:
            if let value: File = value as? File {
                self = .file(key, value.value, value)
                return
            }
        case is CountableSubCollection:
            if let value: CountableSubCollection = value as? CountableSubCollection {
                self = .collection(key, value.value, value)
                return
            }
        case is AnySubCollection:
            if let value: AnySubCollection = value as? AnySubCollection {
                self = .collection(key, [:], value)
                return
            }
        case is AnyReference:
            if let value: AnyReference = value as? AnyReference {
                self = .reference(key, value.value, value)
                return
            }
        case is Object:
            if let value: Object = value as? Object {
                self = .document(key, value.value, value)
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

        DataType.verify(value: value)

        if subjectType == Bool.self {
            if let value: Bool = data[key] as? Bool {
                self = .bool(key, Bool(value), Bool(value))
                return
            }
        } else if subjectType == Int.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int8.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int16.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int32.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Int64.self {
            if let value: Int = data[key] as? Int {
                self = .int(key, Int(value), Int(value))
                return
            }
        } else if subjectType == Float.self {
            if let value: Float = data[key] as? Float {
                self = .float(key, Double(value), Double(value))
                return
            }
        } else if subjectType == Double.self {
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
        } else if subjectType == Data.self || subjectType == Data?.self {
            if let value: Data = data[key] as? Data {
                self = .binary(key, value, value)
                return
            }
        } else if subjectType == GeoPoint.self || subjectType == GeoPoint?.self {
            if let value: GeoPoint = data[key] as? GeoPoint {
                self = .geoPoint(key, value, value)
                return
            }
        } else if subjectType == [Int].self || subjectType == [Int]?.self {
            if let value: [Int] = data[key] as? [Int] {
                self = .array(key, value, value)
                return
            }
        } else if subjectType == [String].self || subjectType == [String]?.self {
            if let value: [String] = data[key] as? [String] {
                self = .array(key, value, value)
                return
            }
        } else if subjectType == [File].self || subjectType == [File]?.self {
            if let value: [[AnyHashable: String]] = data[key] as? [[AnyHashable: String]] {
                let files: [File] = value.flatMap { return File(property: $0) }
                self = .files(key, value, files)
                return
            }
        } else if subjectType == [Any].self || subjectType == [Any]?.self {
            if let value: [Any] = data[key] as? [Any] {
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
                if let file: File = File(property: value) {
                    self = .file(key, value, file)
                    return
                }
            }
        }

        if value is CountableSubCollection {
            let collection: CountableSubCollection = value as! CountableSubCollection
            if let value: [AnyHashable: Any] = data[key] as? [AnyHashable: Any] {
                self = .collection(key, value, collection)
                return
            }
        } else if value is AnySubCollection {
            let collection: AnySubCollection = value as! AnySubCollection
            if let value: [AnyHashable: Any] = data[key] as? [AnyHashable: Any] {
                self = .collection(key, value, collection)
                return
            }
        } else if value is AnyReference {
            if let documentReference: DocumentReference = data[key] as? DocumentReference {
                var reference: AnyReference = value as! AnyReference
                reference.documentReference = documentReference
                self = .reference(key, documentReference, reference)
                return
            }
        } else if value is Object {
            if let rawValue: [AnyHashable: Any] = data[key] as? [AnyHashable: Any] {
                self = .document(key, rawValue, nil)
                return
            }
        } else if value is [String: Any] {
            if let value: [String: Any] = data[key] as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        } else if value is [AnyHashable: Any] {
            if let value: [String: Any] = data[key] as? [String: Any] {
                self = .dictionary(key, value, value)
                return
            }
        } else {
            self = .null
        }
        self = .null
    }

    static func verify(value: Any) {
        let mirror: Mirror = Mirror(reflecting: value)

        let subjectType: Any.Type = mirror.subjectType
        if
                subjectType == Bool?.self ||
                subjectType == Int?.self ||
                subjectType == Int8?.self ||
                subjectType == Int16?.self ||
                subjectType == Int32?.self ||
                subjectType == Int64?.self ||
                subjectType == Float?.self ||
                subjectType == Double?.self {
            fatalError("[Pring.DataType] *** error: Invalid DataType. \(subjectType) is number. Pring not support optional number type." )
        }

        if let displayStyle: Mirror.DisplayStyle = mirror.displayStyle {
            let subjectTypeString: String = String(describing: subjectType)
            if displayStyle == .optional && subjectTypeString.contains("Reference") {
                fatalError("[Pring.DataType] *** error: Invalid DataType. \(subjectType) is Reference. Pring not support optional AnyReference Protocol." )
            }
        }
    }

    internal static func unwrap(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        guard let _: Mirror.DisplayStyle = mirror.displayStyle else {
            return value
        }

        if value is AnySubCollection {
            return value
        }

        if let (label, v) = mirror.children.first {
            if label == "some" {
                return v
            }
            return value
        }
        return nil
    }
}

extension Collection where Iterator.Element == String {
    func toKeys() -> [String: Bool] {
        return reduce(into: [:]) { $0[$1] = true }
    }
}
