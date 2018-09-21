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
    ( { ast = Nothing }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | GetInitialAST
    | GetStepAST
    | ASTReceived (Result Http.Error AST)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetInitialAST ->
            ( model, Request.getInitialAST ASTReceived )

        GetStepAST ->
            case model.ast of
                Just ast ->
                    ( model, Request.getStepAST ASTReceived ast )

                Nothing ->
                    ( model, Cmd.none )

        ASTReceived result ->
            case result of
                Ok ast ->
                    let
                        newModel =
                            { model | ast = Just ast }
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
        , viewAST model.ast
        , button [ onClick GetInitialAST ] [ text "Get initial AST" ]
        , button [ onClick GetStepAST ] [ text "Step" ]
        ]


viewAST : Maybe AST -> Html Msg
viewAST maybeAST =
    [ case maybeAST of
        Nothing ->
            text "No tree"

        Just ast ->
            Tree.drawTree ast
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
