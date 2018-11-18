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

import Bucketchain.Stream (convertToString)
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Node.HTTP as HTTP
import Node.Stream (Readable, Writable)

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
requestBody http = convertToString $ toReadable http

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
