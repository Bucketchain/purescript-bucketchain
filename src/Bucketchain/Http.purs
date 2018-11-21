module Bucketchain.Http
  ( Http
  , toRequest
  , httpStream
  , httpVersion
  , requestHeaders
  , requestMethod
  , requestOriginalURL
  , requestURL
  , requestBody
  , toReadable
  , setHeader
  , setHeaders
  , setRequestURL
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

-- | Convert a HTTP stream to a Request stream.
toRequest :: Http -> HTTP.Request
toRequest (Http { req }) = req

toResponse :: Http -> HTTP.Response
toResponse (Http { res }) = res

-- | Create a HTTP stream.
httpStream :: HTTP.Request -> HTTP.Response -> Http
httpStream req res = Http { req, res }

-- | Get the request HTTP version.
httpVersion :: Http -> String
httpVersion = toRequest >>> HTTP.httpVersion

-- | Get the request headers.
requestHeaders :: Http -> Object String
requestHeaders = toRequest >>> HTTP.requestHeaders

-- | Get the request method (GET, POST, etc.).
requestMethod :: Http -> String
requestMethod = toRequest >>> HTTP.requestMethod

-- | Get the request original URL.
requestOriginalURL :: Http -> String
requestOriginalURL = toRequest >>> _requestOriginalURL

-- | Get the request URL.
requestURL :: Http -> String
requestURL = toRequest >>> HTTP.requestURL

-- | Get the request body.
requestBody :: Http -> Aff String
requestBody = toReadable >>> convertToString

-- | Convert a Http stream to a Readable stream.
toReadable :: Http -> Readable ()
toReadable = toRequest >>> HTTP.requestAsStream

-- | Set a header with a single value.
setHeader :: Http -> String -> String -> Effect Unit
setHeader = toResponse >>> HTTP.setHeader

-- | Set a header with multiple values.
setHeaders :: Http -> String -> Array String -> Effect Unit
setHeaders = toResponse >>> HTTP.setHeaders

-- | Set the request URL.
setRequestURL :: Http -> String -> Effect Unit
setRequestURL = toRequest >>> _setRequestURL

-- | Set the status code.
setStatusCode :: Http -> Int -> Effect Unit
setStatusCode = toResponse >>> HTTP.setStatusCode

-- | Set the status message.
setStatusMessage :: Http -> String -> Effect Unit
setStatusMessage = toResponse >>> HTTP.setStatusMessage

-- | This is for internal. Do not use it.
toWritable :: Http -> Writable ()
toWritable = toResponse >>> HTTP.responseAsStream

foreign import _setRequestURL :: HTTP.Request -> String -> Effect Unit

foreign import _requestOriginalURL :: HTTP.Request -> String
