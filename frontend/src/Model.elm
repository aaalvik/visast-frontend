module Model exposing (..)


type alias Model =
    { steps : Maybe (List AST)
    , input : String
    }


type alias Name =
    String


type alias AST =
    { name : String
    , children : Children
    }


type Children
    = Children (List AST)
