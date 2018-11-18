module Bucketchain
  ( createServer
  , listen
  ) where

import Prelude

import Bucketchain.Middleware (Middleware, runMiddleware)
import Effect (Effect)
import Effect.Console (log)
import Node.HTTP (ListenOptions, Server)
import Node.HTTP as HTTP

-- | Create a HTTP server.
createServer :: Middleware -> Effect Server
createServer = runMiddleware >>> HTTP.createServer

-- | Listen on a port in order to start accepting HTTP requests.
listen :: ListenOptions -> Server -> Effect Unit
listen opts server = HTTP.listen server opts $ logListening opts

logListening :: ListenOptions -> Effect Unit
logListening { hostname, port } = do
  log $ "Listening on " <> hostname <> ":" <> show port
  log $ "Use Ctrl-C to stop"
