# CombineToAsyncAwait
Automatically convert Combine Publishers into Swift 5.5 async methods.

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
        try await self.dataTaskPublisher(for: url).asyncValue()
    }
}

final class NetworkingTests: XCTestCase {
    func testNetworkRequest() async {
        do {
            let (data, response) = try await URLSession.shared.data(for: URL(string: "https://google.com")!)
        } catch {

        }
    }
}

```

Note: Apple has actually introduced async/await versions of this as a part of foundation on iOS 15 and corresponding OSes, so this is only to demonstrate how easy it is to turn a Combine publisher into an `async` method.
