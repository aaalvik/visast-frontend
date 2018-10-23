module Request exposing (parseAndGetSteps)

import Decode
import Encode
import Http


globalUrl : String
globalUrl =
    "http://visast-api.herokuapp.com"


parseAndGetSteps msg inputStr =
    let
        url =
            globalUrl ++ "/steps"

        body =
            Http.jsonBody (Encode.input inputStr)

        request =
            Http.post url body Decode.steps
    in
    Http.send msg request



-- getInitialAST msg =
--     let
--         url =
--             globalUrl ++ "/initial"
--         request =
--             Http.get url Decode.ast
--     in
--     Http.send msg request
-- getStepAST msg ast =
--     let
--         url =
--             globalUrl ++ "/step"
--         body =
--             Http.jsonBody (Encode.ast ast)
--         request =
--             Http.post url body Decode.ast
--     in
--     Http.send msg request
