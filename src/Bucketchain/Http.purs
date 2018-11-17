module Bucketchain.Http
  ( Http
  , httpStream
  , httpVersion
  , requestHeaders
  , requestMethod
  , requestURL
  , requestBody
  , toReadable
  , setHeader
  , setHeaders
  , setStatusCode
  , setStatusMessage
  , toWritable
  ) where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, Canceler, makeAff, nonCanceler)
import Effect.Exception (Error)
import Effect.Ref (modify_, new, read)
import Foreign.Object (Object)
import Node.Encoding (Encoding(..))
import Node.HTTP as HTTP
import Node.Stream (Readable, Writable, onDataString, onEnd, onError)

-- | The type of a HTTP stream.
newtype Http = Http
  { req :: HTTP.Request
  , res :: HTTP.Response
  }

-- | Create a HTTP stream.
httpStream :: HTTP.Request -> HTTP.Response -> Http
httpStream req res = Http { req, res }

-- | Get the request HTTP version.
httpVersion :: Http -> String
httpVersion (Http { req }) = HTTP.httpVersion req

-- | Get the request headers.
requestHeaders :: Http -> Object String
requestHeaders (Http { req }) = HTTP.requestHeaders req

-- | Get the request method (GET, POST, etc.).
requestMethod :: Http -> String
requestMethod (Http { req }) = HTTP.requestMethod req

-- | Get the request URL.
requestURL :: Http -> String
requestURL (Http { req }) = HTTP.requestURL req

-- | Get the request body.
requestBody :: Http -> Aff String
requestBody http = makeAff $ requestBodyImpl http

-- | Convert a Http stream to a Readable stream.
toReadable :: Http -> Readable ()
toReadable (Http { req }) = HTTP.requestAsStream req

-- | Set a header with a single value.
setHeader :: Http -> String -> String -> Effect Unit
setHeader (Http { res }) = HTTP.setHeader res

-- | Set a header with multiple values.
setHeaders :: Http -> String -> Array String -> Effect Unit
setHeaders (Http { res }) = HTTP.setHeaders res

-- | Set the status code.
setStatusCode :: Http -> Int -> Effect Unit
setStatusCode (Http { res }) = HTTP.setStatusCode res

-- | Set the status message.
setStatusMessage :: Http -> String -> Effect Unit
setStatusMessage (Http { res }) = HTTP.setStatusMessage res

-- | This is for internal. Do not use it.
toWritable :: Http -> Writable ()
toWritable (Http { res }) = HTTP.responseAsStream res

requestBodyImpl :: Http -> (Either Error String -> Effect Unit) -> Effect Canceler
requestBodyImpl http cb = do
  let readable = toReadable http
  ref <- new ""
  onDataString readable UTF8 \chunk -> modify_ (flip append chunk) ref
  onError readable \err -> cb $ Left err
  onEnd readable $ Right <$> read ref >>= cb
  pure nonCanceler
