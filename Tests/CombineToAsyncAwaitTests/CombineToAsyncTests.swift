import XCTest
import Combine
@testable import CombineToAsync

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
}
