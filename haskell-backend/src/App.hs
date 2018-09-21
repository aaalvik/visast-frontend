{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module App where

  
import Data.Aeson
import GHC.Generics
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.IO

-- * API

type AstAPI =
  "step" :> ReqBody '[JSON] AST :> Post '[JSON] (Headers '[Header "Access-Control-Allow-Origin" String] AST) :<|>
  "initial" :> Get '[JSON] (Headers '[Header "Access-Control-Allow-Origin" String] AST) 



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
mkApp = return $ serve (Proxy :: Proxy AstAPI) server


frontendUrl :: String 
frontendUrl = "http://localhost:8080"

stepWithHeader :: AST -> Handler (Headers '[Header "Access-Control-Allow-Origin" String] AST)
stepWithHeader ast = addHeader frontendUrl <$> step ast
  where 
    step :: AST -> Handler AST 
    step ast = return ast


initialWithHeader :: Handler (Headers '[Header "Access-Control-Allow-Origin" String] AST)
initialWithHeader = addHeader frontendUrl <$> initial 
  where 
    initial :: Handler AST 
    initial = return initialAST


server :: Server AstAPI
server =
  stepWithHeader :<|> initialWithHeader
 

-- * Types 

data AST = AST {
    name :: Name,  
    children :: [AST]
} deriving (Eq, Show, Generic)


instance ToJSON AST  
instance FromJSON AST 


initialAST :: AST 
initialAST = AST "Node" []


type Name = String 
