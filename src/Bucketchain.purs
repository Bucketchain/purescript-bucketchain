module Bucketchain
  ( Middleware
  , run
  ) where

import Prelude

import Bucketchain.Handler (Handler, runHandler, empty)
import Bucketchain.Http (Http, httpStream, setHeader, setStatusCode, toWritable)
import Bucketchain.ResponseBody (ResponseBody, toReadable, maybeToBody)
import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Effect.Exception (Error)
import Node.HTTP (ListenOptions, Request, Response, createServer, listen)
import Node.Stream (end, onError, pipe)

-- | The type of a middleware.
type Middleware = Handler Http (Maybe ResponseBody) -> Handler Http (Maybe ResponseBody)

-- | Start a server.
run :: ListenOptions -> Middleware -> Effect Unit
run opts middleware = do
  server <- createServer $ serve $ middleware empty
  listen server opts $ logListening opts

serve :: Handler Http (Maybe ResponseBody) -> Request -> Response -> Effect Unit
serve handler req res =
  runAff_ (handleAff http) $ runHandler handler http
  where
    http = httpStream req res

handleAff :: Http -> Either Error (Maybe ResponseBody) -> Effect Unit
handleAff http (Right x) = do
  readable <- toReadable <$> maybeToBody x
  onError readable $ Left >>> handleAff http
  void $ pipe readable $ toWritable http
handleAff http _ = do
  setHeader http "Content-Type" "text/plain; charset=utf-8"
  setStatusCode http 500
  end (toWritable http) $ pure unit

logListening :: ListenOptions -> Effect Unit
logListening { hostname, port } = do
  log $ "Listening on " <> hostname <> ":" <> show port
  log $ "Use Ctrl-C to stop"
