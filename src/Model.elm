module Model exposing (..)


type alias Model =
    { currentAST : Maybe AST
    , requestStatus : RequestStatus 
    , nextSteps : Maybe (List AST)
    , previousSteps : Maybe (List AST)
    , input : Maybe String
    , viewMode : ViewMode 
    , key : Maybe String 
    }


type alias Name =
    String


type alias AST =
    { name : String
    , children : Children
    }


type Children
    = Children (List AST)


type ViewMode = Initial | Advanced | Test 


type RequestStatus
    = Good | InvalidInput | ReceivedError