import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `PredicateHelper` macro. This takes a static @Model class function
/// returning #Predicate macro content and generates a matching member function performing the same
/// logic.

private let returnStringStart = "return #Predicate<"

private enum PredicateHelperMacroError: Error, CustomStringConvertible {
    case noAttachedFunction
    case noPredicate(_ returnString: String)

    var description: String {
        switch self {
        case .noAttachedFunction:
            return "#PredicateHelper acts on a valid attached static function"
        case .noPredicate(let returnString):
            return "#PredicateHelper expects a final string beginning '\(returnStringStart)': \(returnString)"
        }
    }
}

public struct PredicateHelperMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let functionDeclaration = declaration.as(FunctionDeclSyntax.self),
              let functionBody = functionDeclaration.body,
              let predicateType = functionDeclaration.signature.returnClause?.type.trimmedDescription,
              !functionBody.statements.isEmpty else {
            throw PredicateHelperMacroError.noAttachedFunction }
        
        let functionName = functionDeclaration.name.text
        let arguments = functionDeclaration.signature.parameterClause.parameters
        let statements = functionBody.statements.map({ $0.trimmedDescription })
        let predicateStatement = statements.last!
        let type = predicateType.trimmingPrefix(while: { $0 != "<" }).dropFirst().dropLast()
        
        guard predicateStatement.hasPrefix(returnStringStart) else {
            throw PredicateHelperMacroError.noPredicate(predicateStatement) }
        
        let predicateClosure = predicateStatement.trimmingPrefix(while: { $0 != "{" })

        return [DeclSyntax.init(stringLiteral: """
            func \(functionName)(\(arguments)) -> Bool 
            {
                \(statements.dropLast().joined(separator: "\n"))
            
                let decider: (\(type)) -> Bool =  \(predicateClosure) 
            
                return decider(self)
            }
            """)]
    }
}

@main
struct PredicateHelperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PredicateHelperMacro.self,
    ]
}
