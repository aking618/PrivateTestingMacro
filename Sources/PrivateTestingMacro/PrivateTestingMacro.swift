// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces a public version of a method,
///
///     @Testable
///     private func myMethod(_ foo: Int) -> Int {
///         return foo * foo
///     }
///
/// produces a public version,
///
///     public func testableMyMethod(_ foo: Int) -> Int {
///         myMethod(foo)
///     }
@attached(peer, names: overloaded)
public macro Testable() = #externalMacro(module: "PrivateTestingMacroMacros", type: "TestablePeerMacro")
