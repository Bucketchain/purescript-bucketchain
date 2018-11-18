module Bucketchain
  ( run
  ) where

import Prelude

import Bucketchain.Middleware (Middleware, runMiddleware)
import Effect (Effect)
import Effect.Console (log)
import Node.HTTP (ListenOptions, createServer, listen)

-- | Start a server.
run :: ListenOptions -> Middleware -> Effect Unit
run opts middleware = do
  server <- createServer $ runMiddleware middleware
  listen server opts $ logListening opts

logListening :: ListenOptions -> Effect Unit
logListening { hostname, port } = do
  log $ "Listening on " <> hostname <> ":" <> show port
  log $ "Use Ctrl-C to stop"
