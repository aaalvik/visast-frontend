module Main exposing (enterButtonPressed, errorToString, init, main, responseToString, setASTS, setPage, update, updateASTS, validUsername, view)

import Browser
import Browser.Navigation as Nav
import Http exposing (Error(..), Response)
import Model exposing (..)
import Page.Advanced as Advanced
import Page.Easy as Easy
import Page.Index as Index
import Request.Request as Request
import Route
import Tree.Step as Tree
import Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        page =
            Route.urlToPage url

        cmd =
            case page of
                Advanced NotAsked username ->
                    Request.stepsAdvanced (UserStepsReceived username) username

                _ ->
                    Cmd.none
    in
    ( { asts = Nothing
      , exprStr = Nothing
      , usernameStr = ""
      , key = key
      , url = url
      , page = page
      }
    , cmd
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetExprStr str ->
            ( { model
                | exprStr =
                    if String.isEmpty str then
                        Nothing

                    else
                        Just str
              }
            , Cmd.none
            )

        SetUsernameStr str ->
            ( { model | usernameStr = str }, Cmd.none )

        ParseAndGetSteps ->
            case model.exprStr of
                Just str ->
                    ( model, Request.stepsEasy StepsReceived str )

                Nothing ->
                    ( model, Cmd.none )

        StepsReceived result ->
            case result of
                Ok (ast :: next) ->
                    let
                        newModel =
                            model
                                |> updateASTS ast next
                                |> setPage (Easy Good)
                    in
                    ( newModel, Cmd.none )

                Ok [] ->
                    let
                        newModel =
                            model
                                |> setASTS Nothing
                                |> setPage (Easy InvalidInput)
                    in
                    ( newModel, Cmd.none )

                Err err ->
                    let
                        newModel =
                            model
                                |> setASTS Nothing
                                |> setPage (Easy ReceivedError)
                    in
                    ( newModel, Cmd.none )

        UserStepsReceived username result ->
            case result of
                Ok (ast :: next) ->
                    let
                        newModel =
                            model
                                |> updateASTS ast next
                                |> setPage (Advanced Good username)
                    in
                    ( newModel, Cmd.none )

                Ok [] ->
                    let
                        newModel =
                            model
                                |> setASTS Nothing
                                |> setPage (InsertUsername InvalidInput)
                    in
                    ( newModel, Cmd.none )

                Err err ->
                    let
                        newModel =
                            model
                                |> setASTS Nothing
                                |> setPage (InsertUsername ReceivedError)
                    in
                    ( newModel, Cmd.none )

        NextState ->
            ( Tree.nextState model, Cmd.none )

        PreviousState ->
            ( Tree.previousState model, Cmd.none )

        KeyDown key ->
            if key == 13 then
                enterButtonPressed model

            else
                ( model, Cmd.none )

        RefreshSteps username ->
            ( model, Request.stepsAdvanced (UserStepsReceived username) username )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( resetInput { model | url = url, page = Route.urlToPage url }, Cmd.none )


resetInput : Model -> Model
resetInput model =
    { model | exprStr = Nothing, usernameStr = "", asts = Nothing }


setPage : Page -> Model -> Model
setPage newPage model =
    { model | page = newPage }


setASTS : Maybe ASTS -> Model -> Model
setASTS newASTS model =
    { model | asts = newASTS }


updateASTS : AST -> List AST -> Model -> Model
updateASTS ast next model =
    let
        newASTS =
            { current = ast
            , next = next
            , prev = []
            }
    in
    { model | asts = Just newASTS }


enterButtonPressed : Model -> ( Model, Cmd Msg )
enterButtonPressed model =
    let
        username =
            model.usernameStr

        url =
            "/advanced/" ++ String.toLower username
    in
    case model.page of
        InsertUsername _ ->
            if validUsername username then
                ( model
                , Cmd.batch
                    [ Nav.pushUrl model.key url -- Må gjøres før request, fordi denne resetter ReqStatus
                    , Request.stepsAdvanced (UserStepsReceived username) username
                    ]
                )

            else
                ( setPage (InsertUsername InvalidInput) model, Cmd.none )

        Easy _ ->
            case model.exprStr of
                Just str ->
                    ( model, Request.stepsEasy StepsReceived str )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


validUsername : String -> Bool
validUsername _ =
    True



-- TODO implement for input validation


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


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Index ->
            Index.view model

        Advanced status username ->
            Advanced.view model status username

        InsertUsername status ->
            Advanced.viewInsertUsername status

        Easy status ->
            Easy.view model status



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
