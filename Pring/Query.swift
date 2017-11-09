//
//  Query.swift
//  Pring
//
//  Created by 1amageek on 2017/11/08.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

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
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThan: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThanOrEqualTo: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThan: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan), reference: self.reference)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThanOrEqualTo: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
        }

        public func order(by: PartialKeyPath<Element>) -> Query {
            return Query(reference.order(by: by._kvcKeyPathString!), reference: self.reference)
        }

        public func order(by: PartialKeyPath<Element>, descending: Bool) -> Query {
            return Query(reference.order(by: by._kvcKeyPathString!, descending: descending), reference: self.reference)
        }

        public func limit(to: Int) -> Query {
            return Query(reference.limit(to: to), reference: self.reference)
        }

        public func start(at: [Any]) -> Query {
            return Query(reference.start(at: at), reference: self.reference)
        }

        public func start(after: [Any]) -> Query {
            return Query(reference.start(after: after), reference: self.reference)
        }

        public func start(atDocument: DocumentSnapshot) -> Query {
            return Query(reference.start(atDocument: atDocument), reference: self.reference)
        }

        public func start(afterDocument: DocumentSnapshot) -> Query {
            return Query(reference.start(afterDocument: afterDocument), reference: self.reference)
        }

        public func end(at: [Any]) -> Query {
            return Query(reference.end(at: at), reference: self.reference)
        }

        public func end(atDocument: DocumentSnapshot) -> Query {
            return Query(reference.end(atDocument: atDocument), reference: self.reference)
        }

        public func end(before: [Any]) -> Query {
            return Query(reference.end(before: before), reference: self.reference)
        }

        public func end(beforeDocument: DocumentSnapshot) -> Query {
            return Query(reference.end(beforeDocument: beforeDocument), reference: self.reference)
        }

        public func listen(options: QueryListenOptions? = nil, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
            return reference.addSnapshotListener(options: options, listener: listener)
        }

        public func get(completion: @escaping FIRQuerySnapshotBlock) {
            reference.getDocuments(completion: completion)
        }
    }
}
