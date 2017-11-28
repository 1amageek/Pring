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

        public init(_ reference: CollectionReference) {
            self.reference = reference
            self.query = reference
        }

        public init(_ query: FirebaseFirestore.Query, reference: CollectionReference) {
            self.reference = reference
            self.query = query
        }

        public func dataSource() -> DataSource<Element> {
            return DataSource(reference: self)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThan: Any) -> Query {
            return Query(query.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThan: Any) -> Query {
            return Query(query.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
        }

        public func order(by: PartialKeyPath<Element>) -> Query {
            return Query(query.order(by: by._kvcKeyPathString!), reference: self.reference)
        }

        public func order(by: PartialKeyPath<Element>, descending: Bool) -> Query {
            return Query(query.order(by: by._kvcKeyPathString!, descending: descending), reference: self.reference)
        }

        public func limit(to: Int) -> Query {
            return Query(query.limit(to: to), reference: self.reference)
        }

        public func start(at: [Any]) -> Query {
            return Query(query.start(at: at), reference: self.reference)
        }

        public func start(after: [Any]) -> Query {
            return Query(query.start(after: after), reference: self.reference)
        }

        public func start(atDocument: DocumentSnapshot) -> Query {
            return Query(query.start(atDocument: atDocument), reference: self.reference)
        }

        public func start(afterDocument: DocumentSnapshot) -> Query {
            return Query(query.start(afterDocument: afterDocument), reference: self.reference)
        }

        public func end(at: [Any]) -> Query {
            return Query(query.end(at: at), reference: self.reference)
        }

        public func end(atDocument: DocumentSnapshot) -> Query {
            return Query(query.end(atDocument: atDocument), reference: self.reference)
        }

        public func end(before: [Any]) -> Query {
            return Query(query.end(before: before), reference: self.reference)
        }

        public func end(beforeDocument: DocumentSnapshot) -> Query {
            return Query(query.end(beforeDocument: beforeDocument), reference: self.reference)
        }

        public func listen(options: QueryListenOptions? = nil, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
            return query.addSnapshotListener(options: options, listener: listener)
        }

        public func get(completion: @escaping FIRQuerySnapshotBlock) {
            query.getDocuments(completion: completion)
        }
    }
}
