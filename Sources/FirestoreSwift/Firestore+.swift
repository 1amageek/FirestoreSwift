//
//  Firestore.swift
//  
//
//  Created by nori on 2022/05/17.
//

import Foundation
@preconcurrency import FirebaseFirestore
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

extension FirebaseFirestore.Firestore: FirestoreImitation.Firestore, @unchecked @retroactive Sendable {

    public func updates(_ reference: FirestoreImitation.DocumentReference, includeMetadataChanges: Bool) -> AsyncThrowingStream<FirestoreImitation.DocumentSnapshot?, Error>? {
        AsyncThrowingStream { continuation in
            let listener = document(reference.path).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let documentSnapshot else {
                    continuation.yield(nil)
                    return
                }
                let reference = FirestoreImitation.DocumentReference(documentSnapshot.reference.path)
                let data = documentSnapshot.data(with: .estimate)
                let metadata = FirestoreImitation.SnapshotMetadata(pendingWrites: documentSnapshot.metadata.hasPendingWrites, fromCache: documentSnapshot.metadata.isFromCache)
                let snapshot = FirestoreImitation.DocumentSnapshot(reference: reference, data: data, metadata: metadata)
                continuation.yield(snapshot)
            }
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(_ reference: FirestoreImitation.DocumentReference, includeMetadataChanges: Bool, type: T.Type) -> AsyncThrowingStream<T?, Error>? where T : Decodable & Sendable {
        document(reference.path).updates(type: type, includeMetadataChanges: includeMetadataChanges)
    }

    public func get(_ aggrigateQuery: FirestoreImitation.AggregateQuery) async throws -> FirestoreImitation.AggregateQuerySnapshot? {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<FirestoreImitation.AggregateQuerySnapshot?, Error>) -> Void in
            collection(aggrigateQuery.query.path)
                .setPredicates(aggrigateQuery.query.predicates)
                .count
                .getAggregation(source: .server) { aggregateQuerySnapshot, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let aggregateQuerySnapshot else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let snapshot = FirestoreImitation.AggregateQuerySnapshot(query: aggrigateQuery, count: aggregateQuerySnapshot.count.intValue)
                    continuation.resume(returning: snapshot)
                }
        }
    }

    public func updates<T>(_ query: FirestoreImitation.Query, includeMetadataChanges: Bool, type: T.Type) -> AsyncThrowingStream<[T], Error>? where T : Decodable & Sendable {
        collection(query.path)
            .setPredicates(query.predicates)
            .updates(type: type, includeMetadataChanges: includeMetadataChanges)
    }

    public func changes<T>(_ query: FirestoreImitation.Query, includeMetadataChanges: Bool, type: T.Type) -> AsyncThrowingStream<(added: [T], modified: [T], removed: [T]), Error>? where T : Decodable & Sendable {
        collection(query.path)
            .setPredicates(query.predicates)
            .changes(type: type, includeMetadataChanges: includeMetadataChanges)
    }

    public func get<T>(_ query: FirestoreImitation.Query, source: Source, type: T.Type) async throws -> [T]? where T : Decodable & Sendable {
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
    
    public func get(_ reference: FirestoreImitation.DocumentReference, source: Source = .default) async throws -> FirestoreImitation.DocumentSnapshot? {
        try await withCheckedThrowingContinuation { continuation in
            document(reference.path).getDocument(source: source.rawValue) { documentSnapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let documentSnapshot else {
                    continuation.resume(returning: nil)
                    return
                }
                let reference = FirestoreImitation.DocumentReference(documentSnapshot.reference.path)
                let data = documentSnapshot.data(with: .estimate)
                let metadata = FirestoreImitation.SnapshotMetadata(pendingWrites: documentSnapshot.metadata.hasPendingWrites, fromCache: documentSnapshot.metadata.isFromCache)
                let snapshot = FirestoreImitation.DocumentSnapshot(reference: reference, data: data, metadata: metadata)
                continuation.resume(returning: snapshot)
            }
        }
    }

    public func get<T>(_ reference: FirestoreImitation.DocumentReference, source: Source, type: T.Type) async throws -> T? where T : Decodable & Sendable {
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

    public func set<T>(_ data: T, merge: Bool, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable & Sendable {
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
    
    public func set<T>(_ data: T, extensionData: [String: Any], merge: Bool, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable & Sendable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                let encodeData = try Firestore.Encoder().encode(data)
                let mergingData: [String: Any] = encodeData.merging(extensionData) { $1 }
                document(reference.path).setData(mergingData, merge: merge) { error in
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

    public func update<T>(_ data: T, reference: FirestoreImitation.DocumentReference) async throws where T : Encodable & Sendable {
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
    
    public func update<T>(_ data: T, extensionData: [String: Any], reference: FirestoreImitation.DocumentReference) async throws where T : Encodable & Sendable {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                let encodeData = try Firestore.Encoder().encode(data)
                let mergingData: [String: Any] = encodeData.merging(extensionData) { $1 }
                document(reference.path).updateData(mergingData) { error in
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
