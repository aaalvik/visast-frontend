module Request exposing (parseAndGetSteps, getStepsFromStudent)

import Decode
import Encode
import Http


globalUrl : String
globalUrl =
    "https://visast-api-prod.herokuapp.com"


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


getStepsFromStudent msg keyStr = 
    let 
        url = 
            globalUrl ++ "/getStepsFromStudent?studentKey=" ++ keyStr
        
        request = 
            Http.get url Decode.steps
    in
    Http.send msg request 