module Page.Advanced exposing (view, viewInsertUsername)

import Browser
import Helpers.View as View
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (..)


view : Model -> RequestStatus -> String -> Browser.Document Msg
view model status username =
    { title = "VisAST"
    , body =
        [ div [ class "page" ]
            [ div [ class "content" ]
                [ div [ class "top-container" ] <| viewTop model username
                , viewBottom model status
                ]
            ]
        ]
    }


viewInsertUsername : RequestStatus -> Browser.Document Msg
viewInsertUsername status =
    let
        helperText =
            case status of
                InvalidInput ->
                    "Fant ingenting på det brukernavnet, prøv igjen."

                ReceivedError ->
                    "Oops, noe gikk galt😬 Refresh siden og prøv igjen"

                _ ->
                    "Oppgi brukernavn for å starte"
    in
    { title = "VisAST"
    , body =
        [ div [ class "page" ]
            [ div [ class "content" ]
                [ div [ class "top-container" ] []
                , div [ class "ast-container" ]
                    [ div [ class "advanced-entry" ]
                        [ View.textInput "abc123" "key-input" KeyDown SetUsernameStr
                        , strong []
                            [ text helperText
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }


viewTop : Model -> String -> List (Html Msg)
viewTop model username =
    [ View.viewTitle
    , div [ class "buttons" ]
        [ button [ class "button btn", onClick PreviousState ] [ text "Forrige" ]
        , button [ class "button btn", onClick NextState ] [ text "Neste" ]
        , button [ class "button btn", onClick (RefreshSteps username) ] [ text "Last inn på nytt" ]
        ]
    ]


viewBottom : Model -> RequestStatus -> Html Msg
viewBottom model status =
    case status of
        Good ->
            div [ class "ast-container" ]
                [ View.viewAST <| Maybe.map .current model.asts ]

        InvalidInput ->
            div [ class "ast-container" ]
                [ div [ class "advanced-entry" ]
                    [ strong [] [ text "Fant ingenting på det brukernavnet, prøv igjen" ]

                    -- legg inn knapp med "skriv inn på nytt" ?
                    ]
                ]

        NotAsked ->
            div [ class "ast-container" ] []

        ReceivedError ->
            div [ class "ast-container" ]
                [ div [ class "advanced-entry" ]
                    [ strong [] [ text "Oops, noe gikk galt😬 Refresh siden og prøv igjen" ]
                    ]
                ]
