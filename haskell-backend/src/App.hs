{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}

module App where

  
import Data.Aeson
import GHC.Generics
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.IO

-- * API

type AstAPI=
  "step" :> ReqBody '[JSON] AST :> Post '[JSON] AST :<|>
  "initial" :> Get '[JSON] AST 


astAPI :: Proxy AstAPI 
astAPI = Proxy


-- * APP

run :: IO ()
run = do
  let port = 3000
      settings =
        setPort port $
        setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port)) $
        defaultSettings
  runSettings settings =<< mkApp


mkApp :: IO Application
mkApp = return $ serve astAPI server


server :: Server AstAPI
server =
  step :<|>
  getInitialAST


step :: AST -> Handler AST
step ast = return ast 


getInitialAST :: Handler AST
getInitialAST = return initialAST


-- * Types 

data AST = AST {
    name :: Name,  
    children :: [AST]
} deriving (Eq, Show, Generic)


instance ToJSON AST  
instance FromJSON AST 


initialAST = AST "Node" []


type Name = String 
