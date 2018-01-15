//
//  Query.swift
//  Pring
//
//  Created by 1amageek on 2017/11/08.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

extension DataSource {
    public class Query {

        internal var reference: CollectionReference!

        internal var query: FirebaseFirestore.Query!

        internal var hasRealities: Bool!

        public init(_ reference: CollectionReference, hasRealities: Bool = true) {
            self.reference = reference
            self.query = reference
            self.hasRealities = hasRealities
        }

        public init(_ query: FirebaseFirestore.Query, reference: CollectionReference, hasRealities: Bool = true) {
            self.reference = reference
            self.query = query
            self.hasRealities = hasRealities
        }

        public func dataSource() -> DataSource<Element> {
            return DataSource(reference: self)
        }

        // MARK: -

        public func `where`(_ keyPath: PartialKeyPath<Element>, isEqualTo: Any) -> Query {
            guard let key: String = keyPath._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.where(key, isEqualTo: isEqualTo)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThan: Any) -> Query {
            guard let key: String = keyPath._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.where(key, isLessThan: isLessThan)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThanOrEqualTo: Any) -> Query {
            guard let key: String = keyPath._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.where(key, isLessThanOrEqualTo: isLessThanOrEqualTo)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThan: Any) -> Query {
            guard let key: String = keyPath._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.where(key, isGreaterThan: isGreaterThan)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThanOrEqualTo: Any) -> Query {
            guard let key: String = keyPath._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.where(key, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo)
        }

        public func order(by: PartialKeyPath<Element>) -> Query {
            guard let key: String = by._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.order(by: key)
        }

        public func order(by: PartialKeyPath<Element>, descending: Bool) -> Query {
            guard let key: String = by._kvcKeyPathString else {
                fatalError("[Pring.Query] 'keyPath' is not used except for OjbC.")
            }
            return self.order(by: key, descending: descending)
        }

        // MARK: -

        public func `where`(_ keyPath: String, isEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isEqualTo: isEqualTo), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func `where`(_ keyPath: String, isLessThan: Any) -> Query {
            return Query(query.whereField(keyPath, isLessThan: isLessThan), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func `where`(_ keyPath: String, isLessThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func `where`(_ keyPath: String, isGreaterThan: Any) -> Query {
            return Query(query.whereField(keyPath, isGreaterThan: isGreaterThan), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func `where`(_ keyPath: String, isGreaterThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func order(by: String) -> Query {
            return Query(query.order(by: by), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func order(by: String, descending: Bool) -> Query {
            return Query(query.order(by: by, descending: descending), reference: self.reference, hasRealities: self.hasRealities)
        }

        // MARK: -

        public func limit(to: Int) -> Query {
            return Query(query.limit(to: to), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func start(at: [Any]) -> Query {
            return Query(query.start(at: at), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func start(after: [Any]) -> Query {
            return Query(query.start(after: after), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func start(atDocument: DocumentSnapshot) -> Query {
            return Query(query.start(atDocument: atDocument), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func start(afterDocument: DocumentSnapshot) -> Query {
            return Query(query.start(afterDocument: afterDocument), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func end(at: [Any]) -> Query {
            return Query(query.end(at: at), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func end(atDocument: DocumentSnapshot) -> Query {
            return Query(query.end(atDocument: atDocument), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func end(before: [Any]) -> Query {
            return Query(query.end(before: before), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func end(beforeDocument: DocumentSnapshot) -> Query {
            return Query(query.end(beforeDocument: beforeDocument), reference: self.reference, hasRealities: self.hasRealities)
        }

        public func listen(options: QueryListenOptions? = nil, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
            return query.addSnapshotListener(options: options, listener: listener)
        }

        public func get(completion: @escaping FIRQuerySnapshotBlock) {
            query.getDocuments(completion: completion)
        }
    }
}
