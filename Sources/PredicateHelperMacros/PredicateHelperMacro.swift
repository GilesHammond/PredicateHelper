import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Move to Sweeper's much simplified approach: https://stackoverflow.com/a/79008612/978300

@main
struct PredicateHelperPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [PredicateHelperMacro.self]
}

enum PredicateHelperMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var method = declaration.as(FunctionDeclSyntax.self),
              let staticIndex = method.modifiers.firstIndex(where: { $0.name.text == "static" })
        else {
            throw "Must be applied on static method"
        }
        method.modifiers.remove(at: staticIndex)
        method.removeMacro("PredicateHelper")
        method.signature.returnClause?.type = "Bool"
        let argumentList = LabeledExprListSyntax {
            for parameter in method.signature.parameterClause.parameters {
                if parameter.firstName.text != "_" {
                    LabeledExprSyntax(
                        label: parameter.firstName.text,
                        expression: DeclReferenceExprSyntax(baseName: parameter.secondName ?? parameter.firstName)
                    )
                } else {
                    LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: parameter.secondName!))
                }
            }
        }
        let body = CodeBlockItemListSyntax {
            "let predicate = Self.\(raw: method.name)(\(argumentList))"
            "return try! predicate.evaluate(self)"
        }
        method.body?.statements = body
        return [DeclSyntax(method)]
    }
}

extension FunctionDeclSyntax {
    mutating func removeMacro(_ name: String) {
        attributes = attributes.filter { attribute in
            if case let .attribute(attributeSyntax) = attribute,
               let type = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self),
               type.name.text == name {
                return false
            } else {
                return true
            }
        }
    }
}

// Here I conformed String to Error to easily emit diagnostics
extension String: @retroactive Error {}

