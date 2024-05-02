import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import PrivateTestingMacroClient

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PrivateTestingMacroMacros)
import PrivateTestingMacroMacros

let testMacros: [String: Macro.Type] = [
    "Testable": TestablePeerMacro.self,
]
#endif

final class PrivateTestingMacroTests: XCTestCase {

    func testMacro() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod() -> String {
                "Hello"
            }
            """,
            expandedSource: """
            private func myMethod() -> String {
                "Hello"
            }
            
            #if TESTING
            public func testableMyMethod() -> String {
                myMethod()
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacro_NoReturn() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod() {
                
            }
            """,
            expandedSource: """
            private func myMethod() {
                
            }
            
            #if TESTING
            public func testableMyMethod() {
                myMethod()
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_WildCardParam() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod(_ value: Int) -> Int {
                value
            }
            """,
            expandedSource: """
            private func myMethod(_ value: Int) -> Int {
                value
            }
            
            #if TESTING
            public func testableMyMethod(_ value: Int) -> Int {
                myMethod(value)
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_SecondaryNameParam() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod(with value: Int) -> Int {
                value
            }
            """,
            expandedSource: """
            private func myMethod(with value: Int) -> Int {
                value
            }
            
            #if TESTING
            public func testableMyMethod(with value: Int) -> Int {
                myMethod(with: value)
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_GeneralParam() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod(value: Int) -> Int {
                value
            }
            """,
            expandedSource: """
            private func myMethod(value: Int) -> Int {
                value
            }
            
            #if TESTING
            public func testableMyMethod(value: Int) -> Int {
                myMethod(value: value)
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_Generics() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod<T:Hashable>(_ value: T) -> T {
                T
            }
            """,
            expandedSource: """
            private func myMethod<T:Hashable>(_ value: T) -> T {
                T
            }
            
            #if TESTING
            public func testableMyMethod<T: Hashable>(_ value: T) -> T {
                myMethod(value)
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_AllParamTypes() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod(param1: Int, param2 value: Int, _ param3: Int) -> Int {
                param1 + value + param3
            }
            """,
            expandedSource: """
            private func myMethod(param1: Int, param2 value: Int, _ param3: Int) -> Int {
                param1 + value + param3
            }
            
            #if TESTING
            public func testableMyMethod(param1: Int, param2 value: Int, _ param3: Int) -> Int {
                myMethod(param1: param1, param2: value, param3)
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_Async() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod() async {
                
            }
            """,
            expandedSource: """
            private func myMethod() async {
                
            }
            
            #if TESTING
            public func testableMyMethod() async {
                await myMethod()
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_Throws() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod() throws {
                
            }
            """,
            expandedSource: """
            private func myMethod() throws {
                
            }
            
            #if TESTING
            public func testableMyMethod() throws {
                try myMethod()
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacro_AsyncThrows() throws {
        #if canImport(PrivateTestingMacroMacros)
        assertMacroExpansion(
            """
            @Testable
            private func myMethod() async throws {
                
            }
            """,
            expandedSource: """
            private func myMethod() async throws {
                
            }
            
            #if TESTING
            public func testableMyMethod() async throws {
                try await myMethod()
            }
            #endif
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
