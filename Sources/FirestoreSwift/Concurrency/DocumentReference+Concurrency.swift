//
//  DocumentReference+Concurrency.swift
//  
//
//  Created by nori on 2021/10/17.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {

    public func updates(includeMetadataChanges: Bool = false) -> AsyncThrowingStream<DocumentSnapshot, Error> {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                continuation.yield(documentSnapshot!)
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<T, Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { documentSnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    guard let document = try documentSnapshot?.data(as: type) else {
                        return
                    }
                    continuation.yield(document)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
