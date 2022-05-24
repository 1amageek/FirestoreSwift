import XCTest
import FirebaseFirestore
import DocumentID
import FirestoreImitation
@testable import FirestoreSwift

final class FirestoreSwiftTests: XCTestCase {

    func testCodable() throws {

        struct NestData: Identifiable, Codable {
            @DocumentID var id: String
            var number: Int
        }

        struct TopData: Identifiable, Codable {
            @DocumentID var id: String
            var number: Int
            var nest: NestData
        }
        
        let nestData = NestData(id: "0", number: 0)
        let topData = TopData(id: "0", number: 0, nest: nestData)

        let encodedNest = try? Firestore.Encoder().encode(nestData)
        let encodedTop = try? Firestore.Encoder().encode(topData)

        print(encodedNest)
        print(encodedTop)

//        Firestore.Decoder().decode(<#T##T#>, from: <#T##[String : Any]#>)

    }

    func testOptional() throws {

        struct OptionalData: Codable {
            var a: String?
        }

        let encoded = try? Firestore.Encoder().encode(OptionalData(a: nil))

        let data = try? Firestore.Decoder().decode(OptionalData.self, from: encoded!)

    }

    func testIncludeID() throws {

        struct Model: Identifiable, Codable {
            @DocumentID var id: String
        }

        let data = ["id": "0000"]

        let decoded = try? Firestore.Decoder().decode(Model.self, from: data)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
        print("!!", jsonData)
        do {
            let json = try JSONDecoder().decode(Model.self, from: jsonData)
            print("!!", json)
        } catch {
            print(error)
        }
    }

//    func testFieldValue() throws {
//        FieldValueEncoder.shared.setDelegate(FieldValueEncoder.shared)
//        struct Model: Identifiable, Encodable {
//            @DocumentID var id: String
//            var fieldValue: FieldValueEncoder.FieldValue
//        }
//        let data = Model(id: "id", fieldValue: .delete)
//        do {
//            let encoded = try? Firestore.Encoder().encode(data)
//            print(encoded)
//        } catch {
//            print(error)
//        }
//
//    }
}
