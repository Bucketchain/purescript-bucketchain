module Main where

import Prelude

import Bucketchain (createServer, listen)
import Bucketchain.Middleware (Middleware)
import Bucketchain.Http (requestMethod, requestURL, requestBody, setStatusCode, setHeader)
import Bucketchain.ResponseBody (body, fromReadable)
import Control.Monad.Error.Class (throwError)
import Control.Monad.Reader (ask)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Node.FS.Stream (createReadStream)
import Node.HTTP (ListenOptions, Server)

main :: Effect Unit
main = server >>= listen opts

server :: Effect Server
server = createServer middleware

opts :: ListenOptions
opts =
  { hostname: "127.0.0.1"
  , port: 3000
  , backlog: Nothing
  }

middleware :: Middleware
middleware = middleware1 <<< middleware2 <<< middleware3 <<< middleware4

middleware1 :: Middleware
middleware1 next = do
  http <- ask
  if requestMethod http == "GET" && requestURL http == "/test"
    then liftEffect do
      setStatusCode http 200
      setHeader http "Content-Type" "text/plain; charset=utf-8"
      Just <$> body "Hello world :)"
    else next

middleware2 :: Middleware
middleware2 next = do
  http <- ask
  if requestMethod http == "POST" && requestURL http == "/test"
    then do
      b <- liftAff $ requestBody http
      liftEffect do
        setStatusCode http 200
        setHeader http "Content-Type" "text/plain; charset=utf-8"
        Just <$> body b
    else next

middleware3 :: Middleware
middleware3 next = do
  http <- ask
  if requestMethod http == "GET" && requestURL http == "/img"
    then liftEffect do
      setStatusCode http 200
      setHeader http "Content-Type" "image/png"
      Just <<< fromReadable <$> createReadStream "example/300x300.png"
    else next

middleware4 :: Middleware
middleware4 next = do
  http <- ask
  if requestMethod http == "GET" && requestURL http == "/error"
    then throwError $ error "Internal Server Error"
    else next
