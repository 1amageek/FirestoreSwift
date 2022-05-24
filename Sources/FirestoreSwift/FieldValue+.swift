//
//  FieldValue.swift
//  
//
//  Created by nori on 2022/05/24.
//

import Foundation
import FirestoreImitation
import FirebaseFirestore

extension FieldValueEncoder: FieldValueEncodable {

    public func encode(_ value: FirestoreImitation.FieldValue, to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
            case .delete:
                try container.encode(FirebaseFirestore.FieldValue.delete())
            case .serverTimestamp:
                try container.encode(FirebaseFirestore.FieldValue.serverTimestamp())
            case .arrayUnion(let array):
                try container.encode(FirebaseFirestore.FieldValue.arrayUnion(array))
            case .arrayRemove(let array):
                try container.encode(FirebaseFirestore.FieldValue.arrayRemove(array))
            case .increment(let double):
                try container.encode(FirebaseFirestore.FieldValue.increment(double))
        }
    }
}
