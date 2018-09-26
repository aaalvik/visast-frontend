{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module App where


import Types 
import Evaluator 
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.IO
import Network.Wai.Middleware.Cors
import Network.Wai.Middleware.Servant.Options

-- * API

type AstAPI =
  "step" :> ReqBody '[JSON] AST :> Post '[JSON] AST :<|>
  "initial" :> Get '[JSON] AST
  -- "step" :> ReqBody '[JSON] AST :> Post '[JSON] (Headers '[Header "Access-Control-Allow-Origin" String] AST) :<|>
  -- "initial" :> Get '[JSON] (Headers '[Header "Access-Control-Allow-Origin" String] AST) 


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
mkApp = 
  return $ 
  cors (const $ Just policy) $
  provideOptions (Proxy :: Proxy AstAPI) $
  serve (Proxy :: Proxy AstAPI) server
  where 
    policy = simpleCorsResourcePolicy 
              { corsRequestHeaders = [ "content-type" ] 
              , corsMethods = [ "GET", "POST"]
              }


handlerStep :: AST -> Handler AST
handlerStep ast = return $ Evaluator.step ast
    
    
handlerInitial :: Handler AST
handlerInitial = return initialAST


server :: Server AstAPI
server =
  handlerStep :<|> handlerInitial
  -- stepWithHeader :<|> initialWithHeader
 

-- frontendUrl :: String 
-- frontendUrl = "locahhost:8080"


-- stepWithHeader :: AST -> Handler (Headers '[Header "Access-Control-Allow-Origin" String] AST)
-- stepWithHeader ast = addHeader frontendUrl <$> step ast
--   where 
--     step :: AST -> Handler AST 
--     step ast = return stepAST


-- initialWithHeader :: Handler (Headers '[Header "Access-Control-Allow-Origin" String] AST)
-- initialWithHeader = addHeader frontendUrl <$> initial 
--   where 
--     initial :: Handler AST 
--     initial = return initialAST

