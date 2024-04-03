/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import FirebaseFirestore
import struct DocumentID.DocumentID


/// A type that can initialize itself from a Firestore `DocumentReference`,
/// which makes it suitable for use with the `@DocumentID` property wrapper.
///
/// Firestore includes extensions that make `String` and `DocumentReference`
/// conform to `DocumentIDWrappable`.
///
/// Note that Firestore ignores fields annotated with `@DocumentID` when writing
/// so there is no requirement to convert from the wrapped type back to a
/// `DocumentReference`.
public protocol DocumentIDWrappable {
    /// Creates a new instance by converting from the given `DocumentReference`.
    static func wrap(_ documentReference: DocumentReference) throws -> Self
}

extension String: DocumentIDWrappable {
    public static func wrap(_ documentReference: DocumentReference) throws -> Self {
        return documentReference.documentID
    }
}

extension DocumentReference: DocumentIDWrappable {
    public static func wrap(_ documentReference: DocumentReference) throws -> Self {
        // Swift complains that values of type DocumentReference cannot be returned
        // as Self which is nonsensical. The cast forces this to work.
        return documentReference as! Self
    }
}

/// An internal protocol that allows Firestore.Decoder to test if a type is a
/// DocumentID of some kind without knowing the specific generic parameter that
/// the user actually used.
///
/// This is required because Swift does not define an existential type for all
/// instances of a generic class--that is, it has no wildcard or raw type that
/// matches a generic without any specific parameter. Swift does define an
/// existential type for protocols though, so this protocol (to which DocumentID
/// conforms) indirectly makes it possible to test for and act on any
/// `DocumentID<Value>`.
internal protocol DocumentIDProtocol {
    /// Initializes the DocumentID from a DocumentReference.
    init(from documentReference: DocumentReference) throws

    init(from id: String) throws
}

extension DocumentID: DocumentIDProtocol where Value: DocumentIDWrappable {
    // MARK: - `DocumentIDProtocol` conformance

    public init(from documentReference: DocumentReference) throws {
        let value = try Value.wrap(documentReference)
        self.init(wrappedValue: value)
    }

    public init(from id: String) throws {
        self.init(wrappedValue: id  as! Value)
    }
}
