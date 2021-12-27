import XCTest
import Combine
@testable import CombineToAsyncAwait

final class CombineToAsyncTests: XCTestCase {

    enum TestError: Error {
        case testError
    }

    func testExample() async {
        let publisher = Just(true)
        let value = await publisher.firstValue
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

        let value = await publisher.firstValue
        XCTAssertEqual(value, true)
    }

    func testPublisherEmitsMultipleValues() async {
        let publisher = [1, 2].publisher
        let value = await publisher.firstValue
        let result = await publisher.firstResult
        XCTAssertEqual(value, 1)
        XCTAssertEqual(result, .success(1))
    }

    func testExample3() async {
        let publisher = Fail<Bool, Error>(error: TestError.testError)

        do {
            _ = try await publisher.firstValue
            XCTFail("this was supposed to throw")
        } catch {
            XCTAssertEqual(error as? TestError, .testError)
        }
    }

    func testResultSuccess() async {
        let publisher = Just(true)

        let result = await publisher.firstResult
        XCTAssertEqual(result, .success(true))
    }

    func testResultFailure() async {
        let publisher = Fail<Bool, TestError>(error: TestError.testError)

        let result = await publisher.firstResult
        XCTAssertEqual(result, .failure(.testError))
    }

    func testNonThrowingCompleted() async {
        let publisher = Just(())
        await publisher.completed()
    }

    func testThrowingCompletedSucceeded() async throws {
        let publisher = Just(()).setFailureType(to: TestError.self)
        try await publisher.completed()
    }

    func testThrowingCompletedFailed() async throws {
        let publisher = Fail<Bool, TestError>(error: TestError.testError)
        do {
            try await publisher.completed()
            XCTFail("should have thrown")
        } catch {

        }
    }

    func testCompletedResultSucceeded() async {
        let publisher = Just(()).setFailureType(to: TestError.self)
        let result = await publisher.completedResult
        switch result {
        case .failure:
            XCTFail("should have succeeded")
        case.success:
            break
        }
    }

    func testCompletedResultFailed() async {
        let publisher = Fail<Bool, TestError>(error: TestError.testError)
        let result = await publisher.completedResult
        switch result {
        case .failure:
            break
        case.success:
            XCTFail("should have failed")
        }
    }
}
