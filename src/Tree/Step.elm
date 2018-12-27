module Tree.Step exposing (nextState, previousState)

import Model exposing (..)


nextState : Model -> Model
nextState model =
    case ( model.currentAST, model.nextSteps ) of
        ( Just curAST, Just (next :: rest) ) ->
            let
                newPrevSteps =
                    case model.previousSteps of
                        Nothing ->
                            [ curAST ]

                        Just xs ->
                            curAST :: xs
            in
            { model
                | currentAST = Just next
                , nextSteps = Just rest
                , previousSteps = Just newPrevSteps
            }

        _ ->
            model


previousState : Model -> Model
previousState model =
    case ( model.currentAST, model.previousSteps ) of
        ( Just curAST, Just (prev :: rest) ) ->
            let
                newNextSteps =
                    case model.nextSteps of
                        Nothing ->
                            [ curAST ]

                        Just xs ->
                            curAST :: xs
            in
            { model
                | currentAST = Just prev
                , nextSteps = Just newNextSteps
                , previousSteps = Just rest
            }

        _ ->
            model
