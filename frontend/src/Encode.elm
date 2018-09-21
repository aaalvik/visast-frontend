module Encode exposing (ast)

import Json.Encode as Encode
import Model exposing (AST, Children(..))


ast : AST -> Encode.Value
ast tree =
    Encode.object
        [ ( "name", Encode.string tree.name )
        , ( "children", children tree.children )
        ]


children : Children -> Encode.Value
children ch =
    let
        (Children childList) =
            ch
    in
    Encode.list ast childList
