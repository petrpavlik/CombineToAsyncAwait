import Combine
import Foundation

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public extension Publisher where Failure == Never {
    func asyncValue() async -> Output {
        await withCheckedContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.first().sink { value in
                c.resume(returning: value)
                cancellable?.cancel()
            }
        }
    }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public extension Publisher {
    func asyncValue() async throws -> Output {
        try await withCheckedThrowingContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.first().sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    c.resume(throwing: error)
                }
                cancellable?.cancel()
            }, receiveValue: { value in
                c.resume(returning: value)
            })
        }
    }
}
