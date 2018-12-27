module Route exposing (..)

import Model exposing (Page(..))
import Url exposing (Url)
import Url.Parser as Url exposing (Parser, (</>), string)


urlToPage : Url -> Page 
urlToPage url = 
    url
        |> Url.parse urlParser 
        |> Maybe.withDefault Index 

urlParser : Parser (Page -> a) a 
urlParser = 
    Url.oneOf 
        [ Url.map Index Url.top 
        , Url.map Easy (Url.s "easy")
        , Url.map InsertUsername (Url.s "advanced")
        , Url.map Advanced (Url.s "advanced" </> string)
        ]
