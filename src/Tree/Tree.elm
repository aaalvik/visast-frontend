module Tree.Tree exposing (drawTree)

import Helpers.Width as Width
import Html exposing (Html, div, strong, text)
import Model exposing (AST, Children(..))
import Svg exposing (Svg, svg)
import Svg.Attributes as Attrs exposing (..)


type alias EdgePosition =
    ( ( Int, Int ), ( Int, Int ) )


type alias Position =
    ( Int, Int )


edgeColor =
    "#000000"


nodeColor =
    "#51578D"


drawTree : Maybe AST -> Svg msg
drawTree maybeAST =
    case maybeAST of
        Nothing ->
            div [] []

        Just ast ->
            let
                startX =
                    0

                startY =
                    50
            in
            drawSubTree startX startY ast
                |> svg [ class "tree" ]


drawSubTree : Int -> Int -> AST -> List (Svg msg)
drawSubTree xMid y ast =
    let
        totalWidth =
            Width.tree ast

        newY =
            nextY y

        leftX =
            xMid - totalWidth // 2

        (Children children) =
            ast.children

        childrenWidths =
            List.map Width.tree children

        edges =
            drawEdges xMid y totalWidth childrenWidths

        drawnChildren =
            makeChildren xMid newY totalWidth drawSubTree Width.tree children
    in
    case children of
        [] ->
            drawNode xMid y ast.name []

        _ ->
            edges ++ drawNode xMid y ast.name drawnChildren


drawNode : Int -> Int -> String -> List (Svg msg) -> List (Svg msg)
drawNode x y name children =
    let
        wRect =
            Width.node name + 10

        hRect =
            30

        childY =
            nextY y

        xAnchor =
            x - wRect // 2
    in
    [ drawRectangle xAnchor y wRect hRect
    , drawTextInNode name x (y + (hRect // 2))
    ]
        ++ children


drawEdges : Int -> Int -> Int -> List Int -> List (Svg msg)
drawEdges parentX parentY totalWidth childrenWidths =
    let
        xs =
            childrenXs parentX totalWidth childrenWidths
    in
    drawEdgesGivenXs parentX parentY totalWidth xs


drawEdgesGivenXs : Int -> Int -> Int -> List Int -> List (Svg msg)
drawEdgesGivenXs parentX parentY totalWidth xs =
    let
        childrenPos =
            childrenPositions parentX parentY totalWidth xs

        edgePositions =
            List.map (\pos -> ( ( parentX, parentY ), pos )) childrenPos
    in
    List.map drawEdge edgePositions


drawEdge : EdgePosition -> Svg msg
drawEdge ( ( fromX, fromY ), ( toX, toY ) ) =
    Svg.line
        [ x1 (String.fromInt fromX)
        , y1 (String.fromInt <| fromY + 15)
        , x2 (String.fromInt toX)
        , y2 (String.fromInt <| toY + 15)
        , Attrs.style <| "stroke:" ++ edgeColor ++ ";stroke-width:1"
        ]
        []


childrenXs : Int -> Int -> List Int -> List Int
childrenXs parentX totalW childrenWidths =
    let
        leftX =
            parentX - totalW // 2

        marginIfNotFirst prevW =
            if prevW == 0 then
                0

            else
                Width.marginBetween

        xs =
            Tuple.second <|
                List.foldl
                    (\w ( ( curX, prevW ), acc ) ->
                        ( ( curX + w // 2 + prevW // 2 + marginIfNotFirst prevW, w )
                        , acc ++ [ curX + w // 2 + prevW // 2 + marginIfNotFirst prevW ]
                        )
                    )
                    ( ( leftX, 0 ), [] )
                    childrenWidths
    in
    xs


childrenPositions : Int -> Int -> Int -> List Int -> List Position
childrenPositions parentX parentY w xs =
    let
        childY =
            nextY parentY
    in
    List.map (\x -> ( x, childY )) xs


makeChildren : Int -> Int -> Int -> (Int -> Int -> a -> List (Svg msg)) -> (a -> Int) -> List a -> List (Svg msg)
makeChildren x y w drawFunction widthFunction children =
    let
        numChildren =
            List.length children

        childrenWidths =
            List.map widthFunction children

        xs =
            childrenXs x w childrenWidths

        drawnChildren =
            List.concat <| List.map2 (\child curX -> drawFunction curX y child) children xs
    in
    drawnChildren


drawRectangle : Int -> Int -> Int -> Int -> Svg msg
drawRectangle xPos yPos w h =
    Svg.rect [ height (String.fromInt h), width (String.fromInt w), x (String.fromInt xPos), y (String.fromInt yPos), rx "15", ry "15", fill nodeColor ] []


drawTextInNode : String -> Int -> Int -> Svg msg
drawTextInNode name xPos yPos =
    drawText name xPos yPos "white"


drawText : String -> Int -> Int -> String -> Svg msg
drawText name xPos yPos fillColor =
    Svg.g []
        [ Svg.text_ [ dominantBaseline "middle", textAnchor "middle", x (String.fromInt xPos), y (String.fromInt yPos), fill fillColor ] [ text name ] ]


nextY : Int -> Int
nextY y =
    y + marginY


marginY : Int
marginY =
    50
