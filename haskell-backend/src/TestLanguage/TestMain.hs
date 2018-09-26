module TestMain where 

import Evaluator 
import Parser 

testMain = do 
    input <- getLine 
    print $ eval $ parse input 