module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http exposing (Error(..), Response)
import Model exposing (..)
import Request
import Tree


init : ( Model, Cmd Msg )
init =
    ( { steps = Nothing, input = "+ 2 3" }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | ParseAndGetSteps
    | StepsReceived (Result Http.Error (List AST))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ParseAndGetSteps ->
            ( model, Request.parseAndGetSteps StepsReceived model.input )

        StepsReceived result ->
            case result of
                Ok steps ->
                    let
                        newModel =
                            { model | steps = Just steps }
                    in
                    ( newModel, Cmd.none )

                Err err ->
                    Debug.log ("Received error: " ++ errorToString err) ( model, Cmd.none )


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
    div []
        [ h1 [] [ text "Current AST" ]
        , viewAST model.steps
        , button [ onClick ParseAndGetSteps ] [ text "Parse" ]
        ]


viewAST : Maybe (List AST) -> Html Msg
viewAST maybeSteps =
    [ case maybeSteps of
        Nothing ->
            text "No tree"

        Just (ast :: rest) ->
            Tree.drawTree ast

        Just [] ->
            text "Empty list of steps"
    ]
        |> div [ class "tree-container" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
