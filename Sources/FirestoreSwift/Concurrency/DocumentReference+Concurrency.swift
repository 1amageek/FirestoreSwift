//
//  DocumentReference+Concurrency.swift
//  
//
//  Created by nori on 2021/10/17.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {

    public func get<T>(source: FirestoreSource = .default, type: T.Type) async throws -> T? where T: Decodable {
        try await withCheckedThrowingContinuation { continuation in
            self.getDocument(source: source) { documentSnapshot, error in
                do {
                    let document: T? = try documentSnapshot?.data(as: type)
                    continuation.resume(returning: document)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func updates(includeMetadataChanges: Bool = true) -> AsyncThrowingStream<DocumentSnapshot?, Error> {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                continuation.yield(documentSnapshot)
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = true) -> AsyncThrowingStream<T?, Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let document = try documentSnapshot?.data(as: type)
                    continuation.yield(document)
                } catch {
                    print(#function, #line, error)
                    continuation.yield(nil)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = true) -> AsyncThrowingStream<(T?, DocumentSnapshot?), Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let document = try documentSnapshot?.data(as: type)
                    continuation.yield((document, documentSnapshot))
                } catch {
                    print(#function, #line, error)
                    continuation.yield((nil, nil))
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
