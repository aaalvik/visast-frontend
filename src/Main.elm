module Main exposing (Msg(..), errorToString, init, main, onKeyDown, responseToString, textInput, update, view, viewAST, viewBottom, viewLeftMenu, viewTitle, viewTop)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Http exposing (Error(..), Response)
import Json.Decode as Json
import Model exposing (..)
import Request
import Step
import Tree


init : ( Model, Cmd Msg )
init =
    ( { currentAST = Nothing
      , requestStatus = Good 
      , nextSteps = Nothing
      , previousSteps = Nothing
      , input = Nothing
      , viewMode = Initial
      , key = Nothing
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = UpdateInputExpr String
    | UpdateInputKey String
    | ParseAndGetSteps
    | StepsReceived (Result Http.Error (List AST))
    | NextState
    | PreviousState
    | KeyDown Int
    | ChangeMode ViewMode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInputExpr str ->
            ( { model
                | input =
                    if String.isEmpty str then
                        Nothing

                    else
                        Just str
              }
            , Cmd.none
            )

        UpdateInputKey key ->
            ( { model
                | key =
                    if String.isEmpty key then
                        Nothing

                    else
                        Just key
              }
            , Cmd.none
            )

        ParseAndGetSteps ->
            case model.input of
                Just str ->
                    ( model, Request.parseAndGetSteps StepsReceived str )

                Nothing ->
                    ( model, Cmd.none )

        StepsReceived result ->
            case result of
                Ok (ast :: next) ->
                    updateASTs ast next model 

                Ok [] ->
                    ( { model | currentAST = Nothing, requestStatus = InvalidInput }, Cmd.none )

                Err err ->
                    ( { model | currentAST = Nothing, requestStatus = ReceivedError }, Cmd.none )

        NextState ->
            ( Step.nextState model, Cmd.none )

        PreviousState ->
            ( Step.previousState model, Cmd.none )

        KeyDown key ->
            if key == 13 then enterButtonPressed model 
            else
                ( model, Cmd.none )

        ChangeMode newMode ->
            ( { model | viewMode = newMode }, Cmd.none )


updateASTs : AST -> List AST -> Model -> (Model, Cmd Msg)
updateASTs ast next model = 
    let
        currentAST =
            Just ast

        nextSteps =
            Just next

        previousSteps =
            Just []

        requestStatus = 
            Good 

        newModel =
            { model 
                | currentAST = currentAST
                , nextSteps = nextSteps
                , previousSteps = previousSteps
                , requestStatus = Good
            }
    in
    ( newModel, Cmd.none )


enterButtonPressed : Model -> (Model, Cmd Msg)
enterButtonPressed model = 
    case model.viewMode of 
        Initial -> 
            ( model, Cmd.none )

        Advanced -> 
            case model.key of 
                Just keyStr -> 
                    if validKey keyStr then 
                        (model, Request.getStepsFromStudent StepsReceived keyStr)
                    else (model, Cmd.none)

                Nothing -> 
                    (model, Cmd.none)

        Test -> 
            case model.input of
                    Just str ->
                        ( model, Request.parseAndGetSteps StepsReceived str )

                    Nothing ->
                        ( model, Cmd.none )

        
validKey : String -> Bool 
validKey _ = True -- TODO implement for input validation      


errorToString err =
    case err of
        BadUrl str ->
            "BadUrl " ++ str

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus response ->
            "BadStatus: " ++ responseToString response

        BadPayload str response ->
            "BadPayload: " ++ str ++ " -- " ++ responseToString response


responseToString res =
    "Response body = " ++ res.body



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ div [ class "content" ]
            [ div [ class "top-container" ] <| viewTop model
            , viewBottom model
            ]
        ]


viewTop : Model -> List (Html Msg)
viewTop model =
    case model.viewMode of
        Initial ->
            [ viewTitle ]

        Advanced -> 
            [ viewTitle ] ++ (
                case model.currentAST of 
                    Nothing -> [] 
                    Just _ -> 
                        [ div [ class "buttons" ]
                            [ button [ class "button btn", onClick PreviousState ] [ text "Previous" ]
                            , button [ class "button btn", onClick NextState ] [ text "Next" ]
                            ] 
                        ]
            )

        Test ->
            [ div [ class "input-container" ]
                [ textInput "Skriv uttrykk her" "expr-input" UpdateInputExpr
                ]
            , div [ class "buttons" ]
                [ button [ class "button btn", onClick ParseAndGetSteps ] [ text "Parse" ]
                , button [ class "button btn", onClick PreviousState ] [ text "Previous" ]
                , button [ class "button btn", onClick NextState ] [ text "Next" ]
                ]
            ]


viewBottom : Model -> Html Msg
viewBottom model =
    case model.viewMode of
        Initial ->
            [ div [ class "big-button--container" ]
                [ button [ class "button btn big-button", onClick <| ChangeMode Test ] [ text "Bli kjent" ]
                , div [ class "big-button--text" ] [ text "Bli kjent med programmet uten å ha skrevet noe kode." ]
                ]
            , div [ class "big-button--container" ]
                [ button [ class "button btn big-button", onClick <| ChangeMode Advanced ] [ text "Avansert" ]
                , div [ class "big-button--text" ] [ text "Visualiser ved hjelp av din egen evalueringsfunksjon!" ]
                ]
            ] |> div [ class "bottom-container" ]

        Advanced -> 
            viewBottomAdvanced model 

        Test ->
            div [ class "ast-container" ]
            [ viewLeftMenu model
            , (case model.requestStatus of 
                Good -> 
                    viewAST model.currentAST
                
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


viewBottomAdvanced : Model -> Html Msg 
viewBottomAdvanced model = case (model.currentAST, model.requestStatus) of 
    (Nothing, Good) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ textInput "abc123" "key-input" UpdateInputKey 
                , strong [] [ text "Oppgi brukernavn for å starte"]
               ]
            ]

    (_, InvalidInput) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ textInput "abc123" "key-input" UpdateInputKey 
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
             viewAST model.currentAST
            ]

    


viewTitle : Html Msg
viewTitle =
    p [ class "title" ] [ text "VisAST" ]


viewLeftMenu : Model -> Html Msg
viewLeftMenu model =
    div [ class "left-menu" ] <|
        [ div [ class "grammar-container" ]
            [ strong [] [ text "Grammatikk: " ]
            , p [ class "code-font"] [ text "S -> * S S" ]
            , ul [ class "grammar-list code-font"] 
                [ li [] [ text "| + S S" ]
                , li [] [ text "| - S" ]
                , li [] [ text "| if S then S else S" ]
                , li [] [ text "| number" ]
            ]
            ]
        ]


textInput : String -> String -> (String -> Msg) -> Html Msg
textInput str className msg =
    input
        [ class <| "input " ++ className
        , placeholder str
        , onInput msg
        , onKeyDown KeyDown
        ]
        []


viewAST : Maybe AST -> Html Msg
viewAST mast =
    [ Tree.drawTree mast ]
        |> div [ class "tree-container" ]
    


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
