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
  , responseHeader
  , responseHeaders
  , statusCode
  , setHeader
  , setHeaders
  , setRequestURL
  , setStatusCode
  , setStatusMessage
  , toWritable
  , onFinish
  ) where

import Prelude

import Bucketchain.Stream (convertToString)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Node.HTTP as HTTP
import Node.Stream (Readable, Writable)
import Node.Stream as Stream

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

-- | Get a response header value by header name.
responseHeader :: Http -> String -> Maybe String
responseHeader http = toMaybe <<< (_responseHeader $ toResponse http)

-- | Get response header values by header name.
responseHeaders :: Http -> String -> Array String
responseHeaders = toResponse >>> _responseHeaders

-- | Get the status code.
statusCode :: Http -> Int
statusCode = toResponse >>> _statusCode

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

-- | Listen `finish` event of a response stream.
onFinish :: Http -> Effect Unit -> Effect Unit
onFinish = toWritable >>> Stream.onFinish

foreign import _setRequestURL :: HTTP.Request -> String -> Effect Unit

foreign import _requestOriginalURL :: HTTP.Request -> String

foreign import _responseHeader :: HTTP.Response -> String -> Nullable String

foreign import _responseHeaders :: HTTP.Response -> String -> Array String

foreign import _statusCode :: HTTP.Response -> Int
