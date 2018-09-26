module TestLanguage.Convert where 

import TestLanguage.TestTypes 
import Types 

toGeneric :: Expr -> GenericAST 
toGeneric expr = GenericAST "IT WORKED" []