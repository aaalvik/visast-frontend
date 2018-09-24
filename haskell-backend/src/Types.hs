{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Types where 

import Data.Aeson
import GHC.Generics

-- * Types 

data AST = AST {
    name :: Name,  
    children :: [AST]
} deriving (Eq, Show, Generic)


instance ToJSON AST  
instance FromJSON AST 


initialAST :: AST 
initialAST = AST "Node" []


stepAST :: AST 
stepAST = AST "STEPPPPPP" []
 
type Name = String 