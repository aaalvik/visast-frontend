module Model exposing (..)


type alias Model =
    { ast : Maybe AST }


type alias Name =
    String


type alias AST =
    { name : String
    , children : Children
    }


type Children
    = Children (List AST)
