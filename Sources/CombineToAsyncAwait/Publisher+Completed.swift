//
//  File.swift
//  
//
//  Created by Petr Pavlik on 25.12.2021.
//

import Foundation
import Combine

public extension Publisher where Failure == Never {
    func completed() async {
        let _: Void = await withCheckedContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.sink { _ in
                c.resume()
                cancellable?.cancel()
            } receiveValue: { _ in
                // not used
            }
        }
    }
}

public extension Publisher {
    func completed() async throws {
        let _: Void = try await withCheckedThrowingContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.sink { completion in
                switch completion {
                case .finished:
                    c.resume()
                case .failure(let error):
                    c.resume(throwing: error)
                }
                cancellable?.cancel()
            } receiveValue: { _ in
                // not used
            }
        }
    }

    var completedResult: Result<Void, Failure> {
        get async {
            await withCheckedContinuation { c in
                var cancellable: AnyCancellable?
                cancellable = self.sink { completion in
                    switch completion {
                    case .finished:
                        c.resume(returning: .success(()))
                    case .failure(let error):
                        c.resume(returning: .failure(error))
                    }
                    cancellable?.cancel()
                } receiveValue: { _ in
                    // not used
                }
            }
        }
    }
}
