module Model exposing (..)

import Browser.Navigation as Nav
import Browser
import Url 
import Http
import RemoteData exposing (WebData)

type alias Model =
    { currentAST : Maybe AST
    , requestStatus : RequestStatus 
    , nextSteps : Maybe (List AST)
    , previousSteps : Maybe (List AST)
    , exprStr : Maybe String
    , usernameStr : String 
    , key : Nav.Key
    , url : Url.Url 
    , page : Page 
    }


type Msg
    = SetExprStr String
    | SetUsernameStr String
    | ParseAndGetSteps
    | StepsReceived (Result Http.Error (List AST))
    | NextState
    | PreviousState
    | KeyDown Int
    | RefreshSteps 
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url



type alias Name =
    String


type alias AST =
    { name : String
    , children : Children
    }


type Children
    = Children (List AST)


type Page 
    = Index
    | Easy 
    | Advanced


type RequestStatus
    = Good | InvalidInput | ReceivedError