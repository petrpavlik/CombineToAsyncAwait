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

    /// Consider using `.values` on iOS 15.
    func asyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in

            let cancellable = self.sink { completion in
                switch completion {
                case .finished:
                    continuation.finish()
                }
            } receiveValue: { value in
                continuation.yield(value)
            }

            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
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

    /// Consider using `.values` on iOS 15.
    func asyncStream() -> AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream { continuation in

            let cancellable = self.sink { completion in
                switch completion {
                case .finished:
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            } receiveValue: { value in
                continuation.yield(value)
            }

            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }
}
