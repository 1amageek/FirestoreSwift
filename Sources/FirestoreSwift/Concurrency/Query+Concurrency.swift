//
//  Query+Concurrency.swift
//  
//
//  Created by nori on 2021/10/17.
//

import Foundation
import FirebaseFirestore

extension Query {

    public func updates(includeMetadataChanges: Bool = false) -> AsyncThrowingStream<QuerySnapshot, Error> {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { querySnapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        continuation.finish(throwing: error)
                    }
                    return
                }
                DispatchQueue.main.async {
                    continuation.yield(querySnapshot!)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<[T], Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { querySnapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        continuation.finish(throwing: error)
                    }
                    return
                }
                do {
                    let documents: [T] = try querySnapshot?.documents.compactMap({ queryDocumentSnapshot in
                        return try queryDocumentSnapshot.data(as: type)
                    }) ?? []
                    DispatchQueue.main.async {
                        continuation.yield(documents)
                    }
                } catch {
                    DispatchQueue.main.async {
                        continuation.finish(throwing: error)
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}

