module Page.Index exposing (view)

import Model exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Helpers.View as View 


view : Model -> Browser.Document msg
view model = 
    { title = "VisAST"
    , body = 
        [ div [ class "page" ] 
            [ div [ class "content"] 
                [ div [ class "top-container" ] <| [ viewTop model ]
                , viewBottom model
                ]
            ]
        ] 
    }


viewTop : Model -> Html msg
viewTop model = 
    View.viewTitle 


viewBottom : Model -> Html msg 
viewBottom model = 
    [ div [ class "big-button--container" ]
        [ viewBigButton "Bli kjent" "/easy"
        , div [ class "big-button--text" ] [ text "Bli kjent med programmet uten å ha skrevet noe kode." ]
    ]
    , div [ class "big-button--container" ]
        [ viewBigButton "Avansert" "/advanced"
        , div [ class "big-button--text" ] [ text "Visualiser ved hjelp av din egen evalueringsfunksjon!" ]
        ]
    ] |> div [ class "bottom-container" ]


viewBigButton name ref = 
    a [ href ref ]
    [ button 
        [ class "button btn big-button" ] [ text name ]
    ]