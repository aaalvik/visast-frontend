module Page.Advanced exposing (view)


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
    [ View.viewTitle ] ++ (
        case model.currentAST of 
            Nothing -> [] 
            Just _ -> 
                [ div [ class "buttons" ]
                    [ button [ class "button btn", onClick PreviousState ] [ text "Forrige" ]
                    , button [ class "button btn", onClick NextState ] [ text "Neste" ]
                    , button [ class "button btn", onClick RefreshSteps] [ text "Last inn på nytt"]
                    ]
                ]
    )


viewBottom : Model -> Html Msg 
viewBottom model = case (model.currentAST, model.requestStatus) of 
    (Nothing, Good) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ View.textInput "abc123" "key-input" KeyDown SetUsernameStr
                , strong [] [ text "Oppgi brukernavn for å starte"]
               ]
            ]

    (_, InvalidInput) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ View.textInput "abc123" "key-input" KeyDown SetUsernameStr
                , strong [] [ text "Fant ingenting på det brukernavnet, prøv igjen"]
               ]
            ]     

    (_, ReceivedError) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ strong [] [ text "Oops, noe gikk galt😬 Refresh siden og prøv igjen"]
               ]
            ]             

    (Just ast, Good) -> 
        div [ class "ast-container" ]
            [ --viewLeftMenu model
            View.viewAST model.currentAST
            ]
