// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces a public version of a method,
///
///     @PrivateTestable
///     private func myMethod(_ foo: Int) -> Int {
///         return foo * foo
///     }
///
/// produces a public version,
///
///     #if TESTING
///     /// Testing wrapper for myMethod.
///     public func testableMyMethod(_ foo: Int) -> Int {
///         myMethod(foo)
///     }
///     #endif
@attached(peer, names: arbitrary)
public macro PrivateTestable() = #externalMacro(module: "PrivateTestingMacroMacros", type: "PrivateTestablePeerMacro")
