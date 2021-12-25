//
//  File.swift
//  
//
//  Created by Petr Pavlik on 25.12.2021.
//

import Foundation
import Combine

public extension Publisher {
    
    /// Retrieve the first emitted value asynchronously or an error as a `Result` instead of throwing so the error type won't get erased.
    ///
    /// Any following emissions are ignored.
    var firstResult: Result<Output, Failure> {
        get async {
            await withCheckedContinuation { c in
                var cancellable: AnyCancellable?
                cancellable = self.first().sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        c.resume(returning: .failure(error))
                    }
                    cancellable?.cancel()
                }, receiveValue: { value in
                    c.resume(returning: .success(value))
                })
            }
        }
    }
}
