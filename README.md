# CombineToAsyncAwait
Adds `try await myCombineStream.firstValue` and `await myCombineStream.firstResult` for convenient usage because there is no Apple-provided API for it, only to turn a Combine stream into AsyncStream using `.values`.

- https://developer.apple.com/documentation/combine/publisher/values-1dm9r
- https://developer.apple.com/documentation/combine/publisher/values-v7nz

You can use [JohnSundell/AsyncCompatibilityKit](https://swiftpack.co/package/JohnSundell/AsyncCompatibilityKit) to have `.values` backported to iOS 13 and related macOS.

## Example
Let's convert a Combine publisher provided by Apple to make a network request into async/await

Combine implementation
```swift
URLSession.shared.dataTaskPublisher(for: url).sink { completion in
    // check error
} receiveValue: { value in
    // process value
}.store(in: &cancellables)
```

Async/await bridge
```swift
import CombineToAsyncAwait

extension URLSession {
    func data(for url: URL) async throws -> (Data, URLResponse) {
        try await self.dataTaskPublisher(for: url).firstValue
    }
}

final class NetworkingTests: XCTestCase {
    func testNetworkRequest() async throws {
        let (data, response) = try await URLSession.shared.data(for: URL(string: "https://google.com")!)
    }
}

```

Note: Apple has actually introduced async/await versions of this as a part of foundation on iOS 15 and corresponding OSes, so this is only to demonstrate how easy it is to turn a Combine publisher into an `async` method.

### Keeping the Error Type

One of the disadvantages of async/await is that the error gets erased, you can use `firstResult` instead that returns a `Result` type where the error type matches the combine publisher.

```swift
let result = await myApiProvider.userProfile(id: 123).firstResult
switch result {
case .success(let user):
    // ...
case .failure(let fetchUserError):
    switch fetchUserError {
    case .notFound:
        // ...
    }
}
```

### Await Stream Completion

For streams of `void` value, you may want to await stream completion instead of a value.



----

See this package and thousands of others on [swiftpack.co](https://swiftpack.co/package/petrpavlik/CombineToAsyncAwait)
