//
//  Functions+.swift
//  
//
//  Created by nori on 2022/05/18.
//

import Foundation
import FirebaseFunctions
import FunctionsImitation

extension FirebaseFunctions.Functions: FunctionsImitation.Functions {


    func decode<T>(data: Any, type: T.Type, decoder: JSONDecoder) throws -> T where T: Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
        return try decoder.decode(type, from: jsonData)
    }

    public func call<T>(_ callable: FunctionsImitation.Callable<T>, decoder: JSONDecoder = .custom({ $0.dateDecodingStrategy = .formatted(.extendedDateTimeWithMillis()) })) async throws -> T? where T : Decodable {
        return try await withCheckedThrowingContinuation { continuation in
            let httpsCallable: HTTPSCallable
            switch callable.endpoint {
                case .name(let name): httpsCallable = self.httpsCallable(name)
                case .url(let url): httpsCallable = self.httpsCallable(url)
            }
            httpsCallable
                .call(callable.data) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    do {
                        let data = try self.decode(data: result!.data, type: T.self, decoder: decoder)
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    public func request<T>(url: URL, type: T.Type, decoder: JSONDecoder = .custom({ $0.dateDecodingStrategy = .formatted(.extendedDateTimeWithMillis()) })) async throws -> T? where T : Decodable {
        let (data, _) = try await URLSession(configuration: .default).data(from: url)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let decoded = try decode(data: jsonObject, type: type, decoder: decoder)
        return decoded
    }
}
