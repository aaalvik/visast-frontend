module Model exposing (AST, ASTS, Children(..), Model, Msg(..), Name, Page(..), RequestStatus(..))

import Browser
import Browser.Navigation as Nav
import Http
import RemoteData exposing (WebData)
import Url


type alias Model =
    { asts : Maybe ASTS
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
    | UserStepsReceived String (Result Http.Error (List AST))
    | NextState
    | PreviousState
    | KeyDown Int
    | RefreshSteps String
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
    | Easy RequestStatus
    | Advanced RequestStatus String
    | InsertUsername RequestStatus


type RequestStatus
    = Good
    | InvalidInput
    | ReceivedError
    | NotAsked
