module Request.Decode exposing (ast, steps)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Model exposing (AST, Children(..))


ast : Decoder AST
ast =
    Decode.succeed
        AST
        |> required "name" string
        |> required "children" children


children : Decoder Children
children =
    Decode.map Children (Decode.list (Decode.lazy (\_ -> ast)))


steps : Decoder (List AST)
steps =
    Decode.list ast
