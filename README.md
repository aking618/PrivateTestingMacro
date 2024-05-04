# PrivateTestingMacro

Swift Macro that automatically generates a public version of a private function for testing purposes.

## Installation

1. Add the following to your Package.swift file:


```swift
.package(
    url: "https://github.com/aking618/PrivateTestingMacro/tree/main",
    branch: "main"
)
```

2. Add the TESTING compiler directive to both your test target and your main target.

## Usage

```swift
import PrivateTestingMacro

class MyClass {
    @PrivateTestable
    private func privateFunction() {
        print("Hello, World!")
    }
}

class MyClassTests: XCTestCase {
    func testPrivateFunction() {
        let myClass = MyClass()
        myClass.testablePrivateFunction() // Prints: Hello, World!
    }
}
```

Note: The `@PrivateTesting` macro can only be used on functions that are private. If you try to use it on a function that is not private, you will get a compile-time error.

## License

MIT
