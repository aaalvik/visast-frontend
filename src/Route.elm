module Route exposing (urlParser, urlToPage)

import Model exposing (Page(..), RequestStatus(..))
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, string)


urlToPage : Url -> Page
urlToPage url =
    url
        |> Url.parse urlParser
        |> Maybe.withDefault Index


urlParser : Parser (Page -> a) a
urlParser =
    Url.oneOf
        [ Url.map Index Url.top
        , Url.map (Easy NotAsked) (Url.s "easy")
        , Url.map (InsertUsername NotAsked) (Url.s "advanced")
        , Url.map (Advanced NotAsked) (Url.s "advanced" </> string)
        ]
