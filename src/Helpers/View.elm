module Helpers.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder)
import Html.Events exposing (on, keyCode, onInput)
import Model exposing (AST, Model)
import Tree.Tree as Tree
import Json.Decode as Json


viewTitle : Html msg 
viewTitle = 
    p [ class "title" ] [ text "VisAST" ]


viewAST : Maybe AST -> Html msg
viewAST mast =
    [ Tree.drawTree mast ]
        |> div [ class "tree-container" ]


viewLeftMenu : Model -> Html msg
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
    

textInput : String -> String -> (Int -> msg) -> (String -> msg) -> Html msg
textInput str className keyDown msg =
    input
        [ class <| "input " ++ className
        , placeholder str
        , onInput msg
        , onKeyDown keyDown
        ]
        []


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)
