//
//  Query+Queryable.swift
//  
//
//  Created by nori on 2022/05/17.
//

import Foundation
import FirebaseFirestore
import FirestoreImitation

extension FirebaseFirestore.Query: Queryable {

    public typealias DataQuery = FirebaseFirestore.Query

    public func setPredicates(_ predicates: [QueryPredicate]) -> FirebaseFirestore.Query {
        var query = self
        predicates.forEach { predicate in
            switch predicate {
                case .isEqualTo(let field, let value):
                    query = query.whereField(field, isEqualTo: value)
                case .isNotEqualTo(let field, let value):
                    query = query.whereField(field, isNotEqualTo: value)
                case .isIn(let field, let value):
                    query = query.whereField(field, in: value)
                case .isNotIn(let field, let value):
                    query = query.whereField(field, notIn: value)
                case .arrayContains(let field, let value):
                    query = query.whereField(field, arrayContains: value)
                case .arrayContainsAny(let field, let value):
                    query = query.whereField(field, arrayContainsAny: value)
                case .isLessThan(let field, let value):
                    query = query.whereField(field, isLessThan: value)
                case .isGreaterThan(let field, let value):
                    query = query.whereField(field, isGreaterThan: value)
                case .isLessThanOrEqualTo(let field, let value):
                    query = query.whereField(field, isLessThanOrEqualTo: value)
                case .isGreaterThanOrEqualTo(let field, let value):
                    query = query.whereField(field, isGreaterThanOrEqualTo: value)
                case .orderBy(let field, let value):
                    query = query.order(by: field, descending: value)
                case .limitTo(let value):
                    query = query.limit(to: value)
                case .limitToLast(let value):
                    query = query.limit(toLast: value)

                case .isEqualToDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isEqualTo: value)
                case .isNotEqualToDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isNotEqualTo: value)
                case .isInDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), in: value)
                case .isNotInDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), notIn: value)
                case .arrayContainsDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), arrayContains: value)
                case .arrayContainsAnyDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), arrayContainsAny: value)
                case .isLessThanDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isLessThan: value)
                case .isGreaterThanDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isGreaterThan: value)
                case .isLessThanOrEqualToDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isLessThanOrEqualTo: value)
                case .isGreaterThanOrEqualToDocumentID(let value):
                    query = query.whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: value)
            }
        }
        return query
    }
}
