module Model exposing (..)

import Browser.Navigation as Nav
import Url 

type alias Model =
    { currentAST : Maybe AST
    , requestStatus : RequestStatus 
    , nextSteps : Maybe (List AST)
    , previousSteps : Maybe (List AST)
    --, viewMode : ViewMode 
    , exprStr : Maybe String
    , usernameStr : String 
    , key : Nav.Key
    , url : Url.Url 
    , page : Page 
    }


type alias Name =
    String


type alias AST =
    { name : String
    , children : Children
    }


type Children
    = Children (List AST)


--type ViewMode = Initial | Advanced | Test 


type Page 
    = Index
    | Easy 
    | Advanced


type RequestStatus
    = Good | InvalidInput | ReceivedError