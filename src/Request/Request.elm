module Request.Request exposing (stepsAdvanced, stepsEasy)

import Http
import Request.Decode as Decode
import Request.Encode as Encode


globalUrl : String
globalUrl =
    "https://visast-api-prod.herokuapp.com"


stepsEasy msg inputStr =
    let
        url =
            globalUrl ++ "/easy"

        body =
            Http.jsonBody (Encode.input inputStr)

        request =
            Http.post url body Decode.steps
    in
    Http.send msg request


stepsAdvanced msg keyStr =
    let
        url =
            globalUrl ++ "/advanced?lookupKey=" ++ keyStr

        request =
            Http.get url Decode.steps
    in
    Http.send msg request
