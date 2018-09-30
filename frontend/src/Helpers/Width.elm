module Helpers.Width exposing (..)

import Model exposing (AST, Children(..))


tree : AST -> Int
tree ast =
    let
        (Children children) =
            ast.children

        margin =
            (List.length children - 1) * marginBetween
    in
    if List.isEmpty children then
        node ast.name
    else
        margin + (List.sum <| List.map tree children)


node : String -> Int
node name =
    String.length name * wFACTOR + 10


maximum : (a -> Int) -> List a -> Int
maximum widthFunction list =
    List.foldl (\element acc -> Basics.max (widthFunction element) acc) 0 list


marginBetween : Int
marginBetween =
    35


wFACTOR : Int
wFACTOR =
    11
