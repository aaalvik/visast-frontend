module Tree exposing (drawTree)

import Html exposing (Html, div, text)
import Model exposing (AST, Children)


drawTree : AST -> Html msg
drawTree ast =
    let
        (Model.Children childList) =
            ast.children
    in
    div [] <| [ text ast.name ] ++ List.map drawTree childList
