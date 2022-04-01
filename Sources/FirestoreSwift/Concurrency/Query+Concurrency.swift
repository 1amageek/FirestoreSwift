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
                    continuation.finish(throwing: error)
                    return
                }
                continuation.yield(querySnapshot!)
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
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let documents: [T] = try querySnapshot?.documents.compactMap({ queryDocumentSnapshot in
                        return try queryDocumentSnapshot.data(as: type)
                    }) ?? []
                    continuation.yield(documents)
                } catch {
                    print(#function, #line, error)
                    continuation.yield([])
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func updates<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<([T], QuerySnapshot), Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { querySnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let documents: [T] = try querySnapshot?.documents.compactMap({ queryDocumentSnapshot in
                        return try queryDocumentSnapshot.data(as: type)
                    }) ?? []
                    continuation.yield((documents, querySnapshot!))
                } catch {
                    print(#function, #line, error)
                    continuation.yield(([], querySnapshot!))
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func changes<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<(added: [T], modified: [T], removed: [T]), Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { querySnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let changes = querySnapshot?.documentChanges(includeMetadataChanges: includeMetadataChanges) ?? []
                    var added: [T] = []
                    var modified: [T] = []
                    var removed: [T] = []
                    try changes.forEach { documentChange in
                        switch documentChange.type {
                            case .added:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    added.append(document)
                                }
                            case .modified:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    modified.append(document)
                                }
                            case .removed:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    removed.append(document)
                                }
                        }
                    }
                    continuation.yield((added, modified, removed))
                } catch {
                    print(#function, #line, error)
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }

    public func changes<T>(type: T.Type, includeMetadataChanges: Bool = false) -> AsyncThrowingStream<((added: [T], modified: [T], removed: [T]), QuerySnapshot), Error> where T: Decodable {
        AsyncThrowingStream { continuation in
            let listener = self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { querySnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let changes = querySnapshot?.documentChanges(includeMetadataChanges: includeMetadataChanges) ?? []
                    var added: [T] = []
                    var modified: [T] = []
                    var removed: [T] = []
                    try changes.forEach { documentChange in
                        switch documentChange.type {
                            case .added:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    added.append(document)
                                }
                            case .modified:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    modified.append(document)
                                }
                            case .removed:
                                if let document = try documentChange.document.data(as: type, with: .estimate) {
                                    removed.append(document)
                                }
                        }
                    }
                    continuation.yield(((added, modified, removed), querySnapshot!))
                } catch {
                    print(#function, #line, error)
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}

