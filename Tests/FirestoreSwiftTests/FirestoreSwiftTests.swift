import XCTest
import FirebaseFirestore
import DocumentID
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
}
