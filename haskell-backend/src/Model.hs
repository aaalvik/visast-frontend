module Model(GenericAST) where 

-- Needed for encoding and decoding to/from JSON

import GHC.Generics
import Data.Aeson
import Data.Default.Class

-- Needed for generating our bookmark entity

import Database.Persist
import Database.Persist.Class
import Database.Persist.TH

type alias Name = String 

data GenericAST 
    = Tree Name [GenericAST]
    | Leaf Name 

-- share [mkPersist sqlSettings, mkSave "entityDefs"][persistLowerCase|
--   Bookmark
--     -- Two fields
--     title String
--     url   String
--     deriving Show Generic
-- |]

instance ToJSON GenericAST where 
    toJSON (Tree name children) = 
        object [ "name" .= name, "children" .= (map toJSON children) ]
    toJSON (Leaf name) = 
        object [ "name" .= name, "children" .= [] ]

{-
    JSON values - example: 

    { name: "Add"
    , children: [ { name: "3" }, { name: "4" } ]
    }

-}