module Test.Main where

import Prelude

import Bucketchain.Stream (convertToString)
import Bucketchain.Test (request, requestWithBody)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Options ((:=))
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Foreign.Object (lookup)
import Main (server)
import Node.FS.Stream (createReadStream)
import Node.HTTP (Server, listen, close)
import Node.HTTP.Client as C
import Test.Assert (assert)

main :: Effect Unit
main = do
  s <- server
  listen s opts $ runAff_ (handleAff s) do
    testMiddleware1
    testMiddleware2
    testMiddleware3
    testMiddleware4
    test404
  where
    opts =
      { hostname: "localhost"
      , port: 3000
      , backlog: Nothing
      }

handleAff :: Server -> Either Error Unit -> Effect Unit
handleAff _ (Left err) = do
  log $ message err
  assert false
handleAff s _ = close s $ pure unit

testMiddleware1 :: Aff Unit
testMiddleware1 = do
  res <- request opts
  body <- convertToString $ C.responseAsStream res
  liftEffect do
    assert $ body == "Hello world :)"
    assert $ C.statusCode res == 200
    case lookup "content-type" $ C.responseHeaders res of
      Just "text/plain; charset=utf-8" -> assert true
      _ -> assert false
  where
    opts = C.port := 3000
        <> C.method := "GET"
        <> C.path := "/test"

testMiddleware2 :: Aff Unit
testMiddleware2 = do
  res <- requestWithBody opts "TEST BODY"
  body <- convertToString $ C.responseAsStream res
  liftEffect do
    assert $ body == "TEST BODY"
    assert $ C.statusCode res == 200
    case lookup "content-type" $ C.responseHeaders res of
      Just "text/plain; charset=utf-8" -> assert true
      _ -> assert false
  where
    opts = C.port := 3000
        <> C.method := "POST"
        <> C.path := "/test"

testMiddleware3 :: Aff Unit
testMiddleware3 = do
  res <- request opts
  imgStream <- liftEffect $ createReadStream "example/300x300.png"
  expected <- convertToString imgStream
  body <- convertToString $ C.responseAsStream res
  liftEffect do
    assert $ body == expected
    assert $ C.statusCode res == 200
    case lookup "content-type" $ C.responseHeaders res of
      Just "image/png" -> assert true
      _ -> assert false
  where
    opts = C.port := 3000
        <> C.method := "GET"
        <> C.path := "/img"

testMiddleware4 :: Aff Unit
testMiddleware4 = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 500
  where
    opts = C.port := 3000
        <> C.method := "GET"
        <> C.path := "/error"

test404 :: Aff Unit
test404 = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 404
  where
    opts = C.port := 3000
        <> C.method := "GET"
        <> C.path := "/404"
