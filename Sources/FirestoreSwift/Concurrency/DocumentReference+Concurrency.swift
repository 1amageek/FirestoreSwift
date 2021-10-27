//
//  DocumentReference+Concurrency.swift
//  
//
//  Created by nori on 2021/10/17.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {

    public func updates(includeMetadataChanges: Bool = false) -> AsyncThrowingStream<DocumentSnapshot?, Error> {
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

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<T?, Error> where T: Decodable {
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
}
