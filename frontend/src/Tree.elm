module Tree exposing (drawTree)

import Html exposing (Html, div, text)
import Model exposing (AST, Children)


drawTree : Result String AST -> Html msg
drawTree maybeAST =
    case maybeAST of
        Err str ->
            div [] [ text str ]

        Ok ast ->
            draw ast


draw : AST -> Html msg
draw ast =
    let
        (Model.Children childList) =
            ast.children
    in
    div [] <| [ text ast.name ] ++ List.map draw childList
