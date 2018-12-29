module Main exposing (..)

import Browser
import Http exposing (Error(..), Response)
import Model exposing (..)
import Request.Request as Request
import Url
import Tree.Step as Tree 
import Browser.Navigation as Nav 
import Route
import Page.Advanced as Advanced 
import Page.Easy as Easy 
import Page.Index as Index 


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { requestStatus = Good 
    --   , currentAST = Nothing
    --   , nextSteps = Nothing
    --   , previousSteps = Nothing
      , asts = Nothing 
      , exprStr = Nothing
      , usernameStr = ""
      , key = key 
      , url = url 
      , page = Route.urlToPage url
      }
    , Cmd.none
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
                    ( model, Request.parseAndGetSteps StepsReceived str )

                Nothing ->
                    ( model, Cmd.none )

        StepsReceived result ->
            case result of
                Ok (ast :: next) ->
                    (updateASTS ast next model, Cmd.none)

                Ok [] ->
                    ( { model | asts = Nothing, requestStatus = InvalidInput }, Cmd.none )

                Err err ->
                    ( { model | asts = Nothing, requestStatus = ReceivedError }, Cmd.none )

        UserStepsReceived username result -> 
            case result of
                Ok (ast :: next) ->
                    let url = "advanced/" ++ String.toLower username
                    in
                    (updateASTS ast next model, Nav.pushUrl model.key url)

                Ok [] ->
                    ( { model | asts = Nothing, requestStatus = InvalidInput }, Cmd.none )

                Err err ->
                    ( { model | asts = Nothing, requestStatus = ReceivedError }, Cmd.none )
        

        NextState ->
            ( Tree.nextState model, Cmd.none )

        PreviousState ->
            ( Tree.previousState model, Cmd.none )

        KeyDown key ->
            if key == 13 then enterButtonPressed model 
            else
                ( model, Cmd.none )

        RefreshSteps -> 
            (model, Request.getStepsFromStudent StepsReceived model.usernameStr)

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, page = Route.urlToPage url }
            , Cmd.none
            )


updateASTS : AST -> List AST -> Model -> Model
updateASTS ast next model = 
    let
        newASTS = 
            { current = ast 
            , next = next
            , prev = [] 
            }

        newModel =
            { model 
                | asts = Just newASTS
                , requestStatus = Good
            }
        
        url = "advanced/" ++ "raa009"
    in
    newModel


enterButtonPressed : Model -> (Model, Cmd Msg)
enterButtonPressed model = 
    let 
        username = model.usernameStr
    in
    case model.page of 
        InsertUsername -> 
            -- TODO FIX ROUTE 
            if validUsername username then 
                (model, Request.getStepsFromStudent (UserStepsReceived username) username)
            else (model, Cmd.none)

        Easy -> 
            case model.exprStr of
                    Just str ->
                        ( model, Request.parseAndGetSteps StepsReceived str )

                    Nothing ->
                        ( model, Cmd.none )

        _ -> 
            ( model, Cmd.none )

        
validUsername : String -> Bool 
validUsername _ = True -- TODO implement for input validation      


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
        Index -> Index.view model 
        Advanced _ -> Advanced.view model 
        InsertUsername -> Advanced.viewInsertUsername
        Easy -> Easy.view model 


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