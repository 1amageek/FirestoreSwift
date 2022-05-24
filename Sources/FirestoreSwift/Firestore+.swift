//
//  Firestore.swift
//  
//
//  Created by nori on 2022/05/17.
//

import Foundation
import FirebaseFirestore
import FirestoreImitation

extension Source {
    var rawValue: FirestoreSource {
        switch self {
            case .default: return .default
            case .server: return .server
            case .cache: return .cache
        }
    }
}

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
        try await withCheckedThrowingContinuation { continuation in
            collection(query.path).getDocuments(source: source.rawValue) { querySnapshot, error in
                do {
                    let documents: [T] = try querySnapshot?.documents.compactMap({ queryDocumentSnapshot in
                        return try queryDocumentSnapshot.data(as: type)
                    }) ?? []
                    continuation.resume(returning: documents)
                } catch {
                    print(#function, #line, error)
                    continuation.resume(returning: [])
                }
            }
        }
    }

    public func get<T>(_ reference: FirestoreImitation.DocumentReference, source: Source, type: T.Type) async throws -> T? where T : Decodable {
        try await withCheckedThrowingContinuation { continuation in
            document(reference.path).getDocument(source: source.rawValue) { snapshot, error in
                do {
                    let document: T? = try snapshot?.data(as: type)
                    continuation.resume(returning: document)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func create<T>(_ data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try document(reference.path).setData(from: data, merge: true) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume()
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    public func update<T>(before: T?, after: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try document(reference.path).setData(from: after, merge: true) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume()
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    public func update<T>(data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try document(reference.path).setData(from: data, merge: true) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume()
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    public func delete(reference: FirestoreImitation.DocumentReference) async throws {
        try await document(reference.path).delete()
    }
}
