module Request exposing (getInitialAST, getStepAST)

import Decode
import Encode
import Http


globalUrl : String
globalUrl =
    "http://localhost:3000"


getInitialAST msg =
    let
        url =
            globalUrl ++ "/initial"

        request =
            Http.get url Decode.ast
    in
    Http.send msg request


getStepAST msg ast =
    let
        url =
            globalUrl ++ "/step"

        body =
            Http.jsonBody (Encode.ast ast)

        request =
            Http.post url body Decode.ast
    in
    Http.send msg request
