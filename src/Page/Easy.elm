module Page.Easy exposing (view)

import Browser
import Helpers.View as View
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (..)


view : Model -> RequestStatus -> Browser.Document Msg
view model status =
    { title = "VisAST"
    , body =
        [ div [ class "page" ]
            [ div [ class "content" ]
                [ div [ class "top-container" ] <| viewTop model
                , viewBottom model status
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


viewBottom : Model -> RequestStatus -> Html Msg
viewBottom model status =
    div [ class "ast-container" ]
        [ View.viewLeftMenu model
        , case status of
            Good ->
                View.viewAST <| Maybe.map .current model.asts

            InvalidInput ->
                div [ class "ast-container" ]
                    [ div [ class "advanced-entry" ]
                        [ strong [] [ text "Du skrev inn noe ugyldig, sjekk grammatikken igjen" ] ]
                    ]

            NotAsked ->
                div [ class "ast-container" ] []

            ReceivedError ->
                div [ class "ast-container" ]
                    [ div [ class "advanced-entry" ]
                        [ strong [] [ text "Oops, noe gikk galt😬 Refresh siden og prøv igjen" ] ]
                    ]
        ]
