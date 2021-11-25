import XCTest
import Combine
@testable import CombineToAsyncAwait

@available(iOS 15.0, *)
@available(macOS 12.0, *)
final class CombineToAsyncTests: XCTestCase {

    enum TestError: Error {
        case testError
    }

func testExample() async {
        let publisher = Just(true)
        let value = await publisher.asyncValue()
        XCTAssertEqual(value, true)
    }

    func testExample2() async {
        let publisher = Deferred {
            Future<Bool, Never> { completion in
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            }
        }

        let value = await publisher.asyncValue()
        XCTAssertEqual(value, true)
    }

    func testExample3() async {
        let publisher = Fail<Bool, Error>(error: TestError.testError)

        do {
            _ = try await publisher.asyncValue()
            XCTFail("this was supposed to throw")
        } catch {
            XCTAssertEqual(error as? TestError, .testError)
        }
    }

    func testExample4() async {
        let publisher = [0, 1, 2].publisher

        var valuesResult = [Int]()
        for await i in publisher.values {
            valuesResult.append(i)
        }

        var asyncStreamResult = [Int]()
        for await i in publisher.asyncStream() {
            asyncStreamResult.append(i)
        }

        XCTAssertEqual(valuesResult, [0, 1, 2])
        XCTAssertEqual(asyncStreamResult, [0, 1, 2])
    }

//    func testExample5() async {
//        let subject = PassthroughSubject<Int, Error>()
//
//        var valuesResult = [Int]()
//        for await i in publisher.values {
//            valuesResult.append(i)
//        }
//
//        var asyncStreamResult = [Int]()
//        for await i in publisher.asyncStream() {
//            asyncStreamResult.append(i)
//        }
//
//        XCTAssertEqual(valuesResult, [0, 1, 2])
//        XCTAssertEqual(asyncStreamResult, [0, 1, 2])
//    }
}
