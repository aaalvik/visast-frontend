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
import Url
import Browser.Navigation as Nav 
import Route


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { currentAST = Nothing
      , requestStatus = Good 
      , nextSteps = Nothing
      , previousSteps = Nothing
      , exprStr = Nothing
      --, viewMode = Initial
      , usernameStr = ""
      , key = key 
      , url = url 
      , page = Route.urlToPage url
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = SetExprStr String
    | SetUsernameStr String
    | ParseAndGetSteps
    | StepsReceived (Result Http.Error (List AST))
    | NextState
    | PreviousState
    | KeyDown Int
    --| ChangeMode ViewMode
    | RefreshSteps 
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


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

        -- ChangeMode newMode ->
        --     ( { model | viewMode = newMode }, Cmd.none )

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
    case model.page of 
        Index -> 
            ( model, Cmd.none )

        Advanced -> 
            if validUsername model.usernameStr then 
                (model, Request.getStepsFromStudent StepsReceived model.usernameStr)
            else (model, Cmd.none)

        Easy -> 
            case model.exprStr of
                    Just str ->
                        ( model, Request.parseAndGetSteps StepsReceived str )

                    Nothing ->
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
    { title = "VisAST"
    , body = 
        [div [ class "page" ]
            [ div [ class "content" ]
                [ div [ class "top-container" ] <| viewTop model
                , viewBottom model
                ]
            ]
        ]
    }


viewTop : Model -> List (Html Msg)
viewTop model =
    case model.page of
        Index ->
            [ viewTitle ]

        Advanced -> 
            [ viewTitle ] ++ (
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

        Easy ->
            [ div [ class "input-container" ]
                [ textInput "Skriv uttrykk her" "expr-input" SetExprStr
                ]
            , div [ class "buttons" ]
                [ button [ class "button btn", onClick ParseAndGetSteps ] [ text "Parse" ]
                , button [ class "button btn", onClick PreviousState ] [ text "Forrige" ]
                , button [ class "button btn", onClick NextState ] [ text "Neste" ]
                ]
            ]


viewBigButton name ref = 
    a [ href ref ]
    [ button 
        [ class "button btn big-button" ] [ text name ]
    ]

viewBottom : Model -> Html Msg
viewBottom model =
    case model.page of
        Index ->
            [ div [ class "big-button--container" ]
                [ viewBigButton "Bli kjent" "/easy"
                , div [ class "big-button--text" ] [ text "Bli kjent med programmet uten å ha skrevet noe kode." ]
                ]
            , div [ class "big-button--container" ]
                [ viewBigButton "Avansert" "/advanced"
                , div [ class "big-button--text" ] [ text "Visualiser ved hjelp av din egen evalueringsfunksjon!" ]
                ]
            ] |> div [ class "bottom-container" ]

        Advanced -> 
            viewBottomAdvanced model 

        Easy ->
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
                [ textInput "abc123" "key-input" SetUsernameStr
                , strong [] [ text "Oppgi brukernavn for å starte"]
               ]
            ]

    (_, InvalidInput) -> 
        div [ class "ast-container" ]
            [ div [ class "advanced-entry"]
                [ textInput "abc123" "key-input" SetUsernameStr
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
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }