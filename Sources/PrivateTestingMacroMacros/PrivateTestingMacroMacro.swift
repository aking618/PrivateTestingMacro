import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum PrivateTestableDeclError: CustomStringConvertible, Error {
    case onlyApplicableToFunction
    case onlyApplicableToPrivateFunction
    
    public var description: String {
        switch self {
        case .onlyApplicableToFunction:
            "@PrivateTestable can only be applied to a function."
        case .onlyApplicableToPrivateFunction:
            "@PrivateTestable can only be applied to a private function."
        }
    }
}

/// Implementation of the `PrivateTestable` macro, which takes a private function
/// and produces a public version of the method that can be
/// used for unit testing. For example
///
///     @PrivateTestable
///     private func myMethod(_ foo: Int) -> Int {
///         return foo * foo
///     }
///
///  will expand to
///
///     public func testableMyMethod(_ foo: Int) -> Int {
///         myMethod(foo)
///     }
public struct PrivateTestablePeerMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let function = declaration.as(FunctionDeclSyntax.self) else {
            throw PrivateTestableDeclError.onlyApplicableToFunction
        }
        
        guard function.modifiers.contains(where: { $0.name.text == "private" } ) else {
            throw PrivateTestableDeclError.onlyApplicableToPrivateFunction
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
        
        // TODO: Readme with installation, TESTING Flag, example usage
        // TODO: Setup fastlane action to run tests on push
        // TODO: Change name to not confuse macro with existing @PrivateTestable 
        
        let syntax = ""
            .functionPlaceholder()
            .compilerFlag("TESTING")
            .add(.accessor, with: "public")
            .add(.identifier, with: "testable\(modifiedName)")
            .add(.generic, with: genericParameterClause)
            .add(.arguments, with: parameterString)
            .add(.specifier, with: specifier.isEmpty ? " " : specifier)
            .add(.return, with: returnClause.description)
            .add(.body, with: "\(callSpecifier)\(function.name.text)(\(parameterInput))")
            .add(.documentation, with: "/// Testing wrapper for \(function.name.text).")
        
        return [DeclSyntax(stringLiteral: syntax)]
    }
}

fileprivate enum FunctionSyntaxPlaceholder: String {
    case documentation = "DOCUMENTATION"
    case accessor = "ACCESSOR"
    case identifier = "IDENTIFIER"
    case generic = "GENERIC"
    case arguments = "ARGUMENTS"
    case specifier = "SPECIFIER"
    case `return` = "RETURN"
    case body = "BODY"
}

fileprivate extension String {
    func compilerFlag(_ flag: String) -> String {
        """
        #if \(flag)
        \(self)
        #endif
        """
    }
 
    func functionPlaceholder() -> String {
        """
        \(FunctionSyntaxPlaceholder.documentation.rawValue)
        \(FunctionSyntaxPlaceholder.accessor.rawValue) func \(FunctionSyntaxPlaceholder.identifier.rawValue)\(FunctionSyntaxPlaceholder.generic.rawValue)(\(FunctionSyntaxPlaceholder.arguments.rawValue))\(FunctionSyntaxPlaceholder.specifier.rawValue)\(FunctionSyntaxPlaceholder.return.rawValue){
            \(FunctionSyntaxPlaceholder.body.rawValue)
        }
        """
    }
    
    func add(_ placeholder: FunctionSyntaxPlaceholder, with value: String) -> String {
        replaceFirstExpression(of: placeholder.rawValue, with: value)
    }
    
    private func replaceFirstExpression(of pattern: String, with replacement: String) -> String {
        if let range = range(of: pattern) {
            return self.replacingCharacters(in: range, with: replacement)
        } else {
            return self
        }
    }

}


@main
struct PrivateTestingMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PrivateTestablePeerMacro.self,
    ]
}
