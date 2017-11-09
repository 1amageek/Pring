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

        internal var reference: FirebaseFirestore.Query

        public init(_ reference: FirebaseFirestore.Query) {
            self.reference = reference
        }

        public func dataSource() -> DataSource<Element> {
            return DataSource(reference: self)
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isEqualTo: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isEqualTo: isEqualTo))
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThan: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isLessThan: isLessThan))
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isLessThanOrEqualTo: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isLessThanOrEqualTo: isLessThanOrEqualTo))
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThan: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isGreaterThan: isGreaterThan))
        }

        public func `where`(_ keyPath: PartialKeyPath<Element>, isGreaterThanOrEqualTo: Any) -> Query {
            return Query(reference.whereField(keyPath._kvcKeyPathString!, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo))
        }

        public func order(by: PartialKeyPath<Element>) -> Query {
            return Query(reference.order(by: by._kvcKeyPathString!))
        }

        public func order(by: PartialKeyPath<Element>, descending: Bool) -> Query {
            return Query(reference.order(by: by._kvcKeyPathString!, descending: descending))
        }

        public func limit(to: Int) -> Query {
            return Query(reference.limit(to: to))
        }

        public func start(at: [Any]) -> Query {
            return Query(reference.start(at: at))
        }

        public func start(after: [Any]) -> Query {
            return Query(reference.start(after: after))
        }

        public func start(atDocument: DocumentSnapshot) -> Query {
            return Query(reference.start(atDocument: atDocument))
        }

        public func start(afterDocument: DocumentSnapshot) -> Query {
            return Query(reference.start(afterDocument: afterDocument))
        }

        public func end(at: [Any]) -> Query {
            return Query(reference.end(at: at))
        }

        public func end(atDocument: DocumentSnapshot) -> Query {
            return Query(reference.end(atDocument: atDocument))
        }

        public func end(before: [Any]) -> Query {
            return Query(reference.end(before: before))
        }

        public func end(beforeDocument: DocumentSnapshot) -> Query {
            return Query(reference.end(beforeDocument: beforeDocument))
        }

        public func listen(options: QueryListenOptions? = nil, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
            return reference.addSnapshotListener(options: options, listener: listener)
        }

        public func get(completion: @escaping FIRQuerySnapshotBlock) {
            reference.getDocuments(completion: completion)
        }
    }
}
