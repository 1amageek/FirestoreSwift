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
    
    public func updates(_ reference: FirestoreImitation.DocumentReference) -> AsyncThrowingStream<FirestoreImitation.DocumentSnapshot?, Error>? {
        AsyncThrowingStream { continuation in
            let listener = document(reference.path).addSnapshotListener(includeMetadataChanges: false) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let documentSnapshot = documentSnapshot else {
                    continuation.yield(nil)
                    return
                }
                let reference = FirestoreImitation.DocumentReference(documentSnapshot.reference.path)
                let data = documentSnapshot.data(with: .estimate)
                let metadata = FirestoreImitation.SnapshotMetadata(pendingWrites: documentSnapshot.metadata.hasPendingWrites, fromCache: documentSnapshot.metadata.isFromCache)
                let snapshot = FirestoreImitation.DocumentSnapshot(reference: reference, data: data, metadata: metadata)
                continuation.yield(snapshot)
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(_ reference: FirestoreImitation.DocumentReference, type: T.Type) -> AsyncThrowingStream<T?, Error>? where T : Decodable {
        document(reference.path).updates(type: type, includeMetadataChanges: false)
    }

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
    
    public func set(_ data: [String: Any], merge: Bool, reference: FirestoreImitation.DocumentReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            document(reference.path).setData(data, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    public func set<T>(_ data: T, merge: Bool, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try document(reference.path).setData(from: data, merge: merge) { error in
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
    
    public func update(_ data: [String: Any], reference: FirestoreImitation.DocumentReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            document(reference.path).updateData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }

    public func update<T>(_ data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try document(reference.path).updateData(from: data) { error in
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

    public func writeBatch() -> FirestoreImitation.WriteBatch {
        FirestoreImitation.WriteBatch(delegate: batch())
    }

    public func runTransaction(update: @escaping (FirestoreImitation.Transaction, NSErrorPointer) -> Any?, completion: @escaping (Any?, Error?) -> Void) {
        runTransaction { (transaction: FirebaseFirestore.Transaction, errorPointer: NSErrorPointer) in
            return update(FirestoreImitation.Transaction(delegate: transaction), errorPointer)
        } completion: { result, error in
            completion(result, error)
        }
    }
}
