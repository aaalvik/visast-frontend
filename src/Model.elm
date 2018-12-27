module Model exposing (..)

import Browser.Navigation as Nav
import Browser
import Url 
import Http
import RemoteData exposing (WebData)

type alias Model =
    { requestStatus : RequestStatus 
    , asts : Maybe ASTS
    -- , currentAST : Maybe AST
    -- , nextSteps : Maybe (List AST)
    -- , previousSteps : Maybe (List AST)
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


type alias ASTS = 
    { current : AST
    , prev : List AST 
    , next : List AST
    }


type Children
    = Children (List AST)


type Page 
    = Index
    | Easy 
    | Advanced String 
    | InsertUsername


type RequestStatus
    = Good | InvalidInput | ReceivedError