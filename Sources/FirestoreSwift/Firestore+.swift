//
//  Firestore.swift
//  
//
//  Created by nori on 2022/05/17.
//

import Foundation
import FirebaseFirestore
import FirestoreImitation

extension FirebaseFirestore.Firestore: FirestoreImitation.Firestore {

    public func updates<T>(_ query: FirestoreImitation.Query, type: T.Type) -> AsyncThrowingStream<[T], Error>? where T : Decodable {
        collection(query.path)
            .setPredicates(query.predicates)
            .updates(type: type)
    }

    public func changes<T>(_ query: FirestoreImitation.Query, type: T.Type) -> AsyncThrowingStream<(added: [T], modified: [T], removed: [T]), Error>? where T : Decodable {
        collection(query.path)
            .setPredicates(query.predicates)
            .changes(type: type)
    }

    public func get<T>(_ query: FirestoreImitation.Query, source: Source, type: T.Type) async throws -> [T]? where T : Decodable {
        return nil
    }

    public func get<T>(_ reference: FirestoreImitation.DocumentReference, source: Source, type: T.Type) async throws -> T? where T : Decodable {
        try await withCheckedThrowingContinuation { continuation in
            document(reference.path).getDocument { snapshot, error in
                do {
                    let document: T? = try snapshot?.data(as: type)
                    continuation.resume(returning: document)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func create<T>(_ data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable, T : Identifiable {
        try document(reference.path).setData(from: data)
    }

    public func update<T>(before: T?, after: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable, T : Identifiable {

    }

    public func delete<T>(_ data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable, T : Identifiable {

    }
}
