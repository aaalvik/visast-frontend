module Main exposing (..)

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
    ( { currentAST = Err ""
      , nextSteps = Nothing
      , previousSteps = Nothing
      , input = Nothing
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = UpdateInput String
    | ParseAndGetSteps
    | StepsReceived (Result Http.Error (List AST))
    | NextState
    | PreviousState
    | KeyDown Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput str ->
            ( { model
                | input =
                    if String.isEmpty str then
                        Nothing
                    else
                        Just str
              }
            , Cmd.none
            )

        ParseAndGetSteps ->
            case model.input of
                Just str ->
                    ( model, Request.parseAndGetSteps StepsReceived str )

                Nothing ->
                    ( { model | currentAST = Err "Cannot parse empty expression" }, Cmd.none )

        StepsReceived result ->
            case result of
                Ok (ast :: next) ->
                    let
                        currentAST =
                            Ok ast

                        nextSteps =
                            Just next

                        previousSteps =
                            Just []

                        newModel =
                            { model | currentAST = currentAST, nextSteps = nextSteps, previousSteps = previousSteps }
                    in
                    ( newModel, Cmd.none )

                Ok [] ->
                    Debug.log "Received empty list of steps"
                        ( { model | currentAST = Err "Received empty list of steps" }, Cmd.none )

                Err err ->
                    Debug.log ("Received error: " ++ errorToString err)
                        ( { model | currentAST = Err <| "Received error: " ++ errorToString err }, Cmd.none )

        NextState ->
            ( Step.nextState model, Cmd.none )

        PreviousState ->
            ( Step.previousState model, Cmd.none )

        KeyDown key ->
            if key == 13 then
                case model.input of
                    Just str ->
                        ( model, Request.parseAndGetSteps StepsReceived str )

                    Nothing ->
                        ( { model | currentAST = Err "Cannot parse empty expression" }, Cmd.none )
            else
                ( model, Cmd.none )


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
    div [ class "page" ] [ viewContent model ]


viewContent : Model -> Html Msg
viewContent model =
    div [ class "content" ]
        [ div [ class "top-container" ]
            [ [ textInput ] |> div [ class "input-container" ]
            , div [ class "buttons" ]
                [ button [ class "button btn", onClick ParseAndGetSteps ] [ text "Parse" ]
                , button [ class "button btn", onClick PreviousState ] [ text "Previous" ]
                , button [ class "button btn", onClick NextState ] [ text "Next" ]
                ]
            ]
        , viewAST model.currentAST
        ]


textInput : Html Msg
textInput =
    input
        [ class "input"
        , placeholder "Write expression here"
        , onInput UpdateInput
        , onKeyDown KeyDown
        ]
        []


viewAST : Result String AST -> Html Msg
viewAST ast =
    [ [ Tree.drawTree ast ]
        |> div [ class "tree-container" ]
    ]
        |> div [ class "ast-container" ]


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
