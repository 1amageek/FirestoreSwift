//
//  Storage+.swift
//
//
//  Created by nori on 2022/05/18.
//

import Foundation
import FirebaseStorage
import StorageImitation

public protocol FileTransfer {
    var data: Data { get }
}

public enum FileOperationType: Sendable {
    case add
    case delete
    case nochange
}

public struct FileOperation<T: FileTransfer & Sendable>: Sendable {

    public typealias StorageFile = T

    public typealias Result = (FileOperationType, T)

    public typealias Operation = @Sendable (T) async throws -> Self.Result

    public var file: T

    public var path: String

    public var operation: Operation

    public init(file: T, path: String, operation: @escaping Operation) {
        self.file = file
        self.path = path
        self.operation = operation
    }

    public func excute() async throws -> Self.Result {
        return try await self.operation(file)
    }
}

extension FirebaseStorage.Storage: StorageImitation.Storage, @retroactive @unchecked Sendable {

    public func putData(ref: StorageImitation.StorageReference, data: Data, metadata: StorageImitation.StorageMetadata) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            let _metadata = FirebaseStorage.StorageMetadata()
            _metadata.cacheControl = metadata.cacheControl
            _metadata.contentDisposition = metadata.contentDisposition
            _metadata.contentEncoding = metadata.contentEncoding
            _metadata.contentLanguage = metadata.contentLanguage
            _metadata.contentType = metadata.contentType
            _metadata.customMetadata = metadata.customMetadata
            reference().child(ref.fullPath).putData(data, metadata: _metadata) { metadata, error in
                if let error = error {
                    print(error)
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    /// Download data from Firebase Storage
    /// - Parameters:
    ///   - ref: StorageReference that download file
    ///   - maxSize: File size limitation. default llimit 3MB
    /// - Returns: Storage file data
    public func getData(ref: StorageImitation.StorageReference, maxSize: Int64 = 3 * 1024 * 1024) async throws -> Data {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) -> Void in
            reference().child(ref.fullPath).getData(maxSize: maxSize) { data, error in
                if let data {
                    continuation.resume(returning: data)
                } else if let error {
                    print(error)
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: StorageError.internalError(message: "Internal failure in getResultCallback"))
                }
            }
        }
    }

    public func delete(ref: StorageImitation.StorageReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            reference().child(ref.fullPath).delete { error in
                if let error = error {
                    print(error)
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

