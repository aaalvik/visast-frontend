module Tree.Step exposing (nextState, previousState)

import Model exposing (..)


nextState : Model -> Model
nextState model =
    case model.asts of 
        Just asts ->
            case asts.next of 
                (ast :: rest) -> 
                    let 
                        newASTS = 
                            { asts 
                                | current = ast 
                                , next = rest
                                , prev = asts.current :: asts.prev
                            }
                    in 
                    { model | asts = Just newASTS } 

                [] -> 
                    model 
        Nothing -> 
            model 


previousState : Model -> Model
previousState model =
    case model.asts of 
        Just asts -> 
            case asts.prev of 
                (ast :: rest) -> 
                    let 
                        newASTS = 
                            { asts 
                                | current = ast 
                                , prev = rest 
                                , next = asts.current :: asts.next
                            }
                    in 
                    { model | asts = Just newASTS }

                [] ->
                    model 
        Nothing -> 
            model 