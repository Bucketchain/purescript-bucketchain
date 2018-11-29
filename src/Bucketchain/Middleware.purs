module Bucketchain.Middleware
  ( Handler
  , Middleware
  , runMiddleware
  ) where

import Prelude

import Bucketchain.Http (Http, httpStream, setHeader, setStatusCode, toWritable)
import Bucketchain.ResponseBody (ResponseBody, toReadable, maybeToBody)
import Control.Alt (class Alt)
import Control.Monad.Error.Class (class MonadError, class MonadThrow)
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Plus (class Plus)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (Error)
import Node.HTTP (Request, Response)
import Node.Stream (end, onError, pipe)

-- | The type of a HTTP handler.
newtype Handler a = Handler (ReaderT Http Aff a)

derive newtype instance functorHander :: Functor Handler
derive newtype instance applyHander :: Apply Handler
derive newtype instance applicativeHander :: Applicative Handler
derive newtype instance altHandler :: Alt Handler
derive newtype instance plusHandler :: Plus Handler
derive newtype instance bindHandler :: Bind Handler
derive newtype instance monadHandler :: Monad Handler
derive newtype instance semigroupHandler :: Semigroup a => Semigroup (Handler a)
derive newtype instance monoidHandler :: Monoid a => Monoid (Handler a)
derive newtype instance monadEffectHandler :: MonadEffect Handler
derive newtype instance monadAffHandler :: MonadAff Handler
derive newtype instance monadThrowHandler :: MonadThrow Error Handler
derive newtype instance monadErrorHandler :: MonadError Error Handler
derive newtype instance monadAskHandler :: MonadAsk Http Handler
derive newtype instance monadRecHandler :: MonadRec Handler

-- | The type of a middleware.
type Middleware = Handler (Maybe ResponseBody) -> Handler (Maybe ResponseBody)

-- | This is for internal. Do not use it.
runMiddleware
  :: Middleware
  -> Request
  -> Response
  -> Effect Unit
runMiddleware middleware = runHandler $ middleware empty

runHandler
  :: Handler (Maybe ResponseBody)
  -> Request
  -> Response
  -> Effect Unit
runHandler (Handler h) req res =
  runAff_ (handleAff http) $ runReaderT h http
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

empty :: Handler (Maybe ResponseBody)
empty = do
  http <- ask
  liftEffect do
    setStatusCode http 404
    setHeader http "Content-Type" "text/plain; charset=utf-8"
    pure Nothing
