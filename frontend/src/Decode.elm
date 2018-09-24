module Decode exposing (ast)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Model exposing (AST, Children(..))


ast : Decoder AST
ast =
    Debug.log "Decoder::"
        (Decode.succeed
            AST
            |> required "name" string
            |> required "children" children
        )


children : Decoder Children
children =
    Decode.map Children (Decode.list (Decode.lazy (\_ -> ast)))
