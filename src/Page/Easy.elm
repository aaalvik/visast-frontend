module Page.Easy exposing (view)

import Model exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Helpers.View as View 


view : Model -> Browser.Document Msg
view model = 
    { title = "VisAST"
    , body = 
        [ div [ class "page" ] 
            [ div [ class "content"] 
                [ div [ class "top-container" ] <| viewTop model
                , viewBottom model
                ]
            ]
        ] 
    }


viewTop : Model -> List (Html Msg)
viewTop model = 
    [ div [ class "input-container" ]
        [ View.textInput "Skriv uttrykk her" "expr-input" KeyDown SetExprStr ]
    , div [ class "buttons" ]
        [ button [ class "button btn", onClick ParseAndGetSteps ] [ text "Parse" ]
        , button [ class "button btn", onClick PreviousState ] [ text "Forrige" ]
        , button [ class "button btn", onClick NextState ] [ text "Neste" ]
        ]
    ]


viewBottom : Model -> Html Msg 
viewBottom model = 
    div [ class "ast-container" ]
        [ View.viewLeftMenu model
        , (case model.requestStatus of 
            Good -> 
                View.viewAST model.currentAST

            InvalidInput -> 
                div [ class "ast-container" ]
                    [ div [ class "advanced-entry"]
                        [ strong [] [ text "Du skrev inn noe ugyldig, sjekk grammatikken igjen" ] ]
                            ]

            ReceivedError -> 
                div [ class "ast-container" ]
                    [ div [ class "advanced-entry"]
                        [ strong [] [ text "Oops, noe gikk galt😬 Refresh siden og prøv igjen"] ]
                    ]                     
        )
        ]