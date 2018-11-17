module Bucketchain.Handler
  ( Handler
  , empty
  , runHandler
  ) where

import Prelude

import Bucketchain.Http (Http, setHeader, setStatusCode)
import Bucketchain.ResponseBody (ResponseBody)
import Control.Alt (class Alt)
import Control.Monad.Error.Class (class MonadError, class MonadThrow)
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.Rec.Class (class MonadRec)
import Control.Plus (class Plus)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (Error)

-- | The type of a HTTP handler.
newtype Handler r a = Handler (ReaderT r Aff a)

derive newtype instance functorHander :: Functor (Handler r)
derive newtype instance applyHander :: Apply (Handler r)
derive newtype instance applicativeHander :: Applicative (Handler r)
derive newtype instance altHandler :: Alt (Handler r)
derive newtype instance plusHandler :: Plus (Handler r)
derive newtype instance bindHandler :: Bind (Handler r)
derive newtype instance monadHandler :: Monad (Handler r)
derive newtype instance semigroupHandler :: Semigroup a => Semigroup (Handler r a)
derive newtype instance monoidHandler :: Monoid a => Semigroup (Handler r a)
derive newtype instance monadEffHandler :: MonadEffect (Handler r)
derive newtype instance monadAffHandler :: MonadAff (Handler r)
derive newtype instance monadThrowHandler :: MonadThrow Error (Handler r)
derive newtype instance monadErrorHandler :: MonadError Error (Handler r)
derive newtype instance monadAskHandler :: MonadAsk r (Handler r)
derive newtype instance monadRecHandler :: MonadRec (Handler r)

-- | This is for internal. Do not use it.
empty :: Handler Http (Maybe ResponseBody)
empty = do
  http <- ask
  liftEffect do
    setStatusCode http 404
    setHeader http "Content-Type" "text/plain; charset=utf-8"
    pure Nothing

-- | This is for internal. Do not use it.
runHandler :: forall r a. Handler r a -> r -> Aff a
runHandler (Handler x) = runReaderT x
