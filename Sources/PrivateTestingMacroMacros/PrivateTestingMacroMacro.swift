import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum TestableDeclError: CustomStringConvertible, Error {
    case onlyApplicableToFunction
    
    public var description: String {
        switch self {
        case .onlyApplicableToFunction:
            "@Testable can only be applied to a function."
        }
    }
}

/// Implementation of the `Testable` macro, which takes a function
/// and produces a public version of the method that can be
/// used for unit testing. For example
///
///     @Testable
///     private func myMethod(_ foo: Int) -> Int {
///         return foo * foo
///     }
///
///  will expand to
///
///     public func testableMyMethod(_ foo: Int) -> Int {
///         myMethod(foo)
///     }
public struct TestablePeerMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let function = declaration.as(FunctionDeclSyntax.self) else {
            throw TestableDeclError.onlyApplicableToFunction
        }
        
        let signature = function.signature
        
        let modifiedName = function.name.text.prefix(1).uppercased() + function.name.text.dropFirst()
        let returnClause = signature.returnClause?.description ?? ""
        let genericParameterClause = function.genericParameterClause?.description ?? ""
        
        let specifier = signature.effectSpecifiers?.description ?? ""
        let asyncSpecifier = signature.effectSpecifiers?.asyncSpecifier?.description ?? ""
        let throwsSpecifier = signature.effectSpecifiers?.throwsSpecifier?.description ?? ""
        let callSpecifier = asyncSpecifier.isEmpty ?
                                throwsSpecifier.isEmpty ?
                                    "" : "try "
                                : throwsSpecifier.isEmpty ?
                                    "await " : "try await "
        
        let parameterList = signature.parameterClause.parameters
        let parameterString = parameterList.description
        
        let parameterInput = parameterList.map {
            let comma = $0.trailingComma ?? ""
            guard let secondName = $0.secondName else {
                return "\($0.firstName.text)\($0.colon.text) \($0.firstName.text)\(comma)"
            }
            
            var parameterString = ""
            
            if $0.firstName.text != "_" {
                parameterString += "\($0.firstName.text)\($0.colon.text) "
            }
            
            return parameterString + "\(secondName.text)\(comma)"
        }.joined(separator: "")
        
        return [DeclSyntax(stringLiteral: """
                #if TESTING
                public func testable\(modifiedName)\(genericParameterClause)(\(parameterString))\(specifier)\(specifier.isEmpty ? " " : "")\(returnClause.description){
                    \(callSpecifier)\(function.name.text)(\(parameterInput))
                }
                #endif
                """)]
    }
}

@main
struct PrivateTestingMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TestablePeerMacro.self,
    ]
}
