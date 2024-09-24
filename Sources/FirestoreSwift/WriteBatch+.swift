//
//  WriteBatch+.swift
//  
//
//  Created by nori on 2022/05/25.
//

import Foundation
import FirebaseFirestore
import FirestoreImitation

extension FirebaseFirestore.WriteBatch: FirestoreImitation.WriteBatchDelegate, @retroactive @unchecked Sendable {

    public func setData<T>(_ data: T, for document: FirestoreImitation.DocumentReference, merge: Bool) throws where T : Encodable & Sendable {
        try setData(from: data, forDocument: FirebaseFirestore.Firestore.firestore().document(document.path), merge: merge)
    }

    public func updateData<T>(_ data: T, for document: FirestoreImitation.DocumentReference) throws where T : Encodable & Sendable {
        let fields = try FirebaseFirestore.Firestore.Encoder().encode(data)
        updateData(fields, forDocument: FirebaseFirestore.Firestore.firestore().document(document.path))
    }

    public func deleteDocument(_ document: FirestoreImitation.DocumentReference) {
        deleteDocument(FirebaseFirestore.Firestore.firestore().document(document.path))
    }
}
