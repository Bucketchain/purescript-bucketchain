module Bucketchain.Test where

import Prelude

import Data.Either (Either(..))
import Data.Options (Options)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Node.Encoding (Encoding(..))
import Node.HTTP.Client as C
import Node.Stream (end, writeString)

-- | A request test helper.
request :: Options C.RequestOptions -> Aff C.Response
request opts = makeAff \cb -> do
  let cb' res = cb $ Right res
  req <- C.request opts cb'
  end (C.requestAsStream req) $ pure unit
  pure nonCanceler

-- | A request test helper with request body.
requestWithBody :: Options C.RequestOptions -> String -> Aff C.Response
requestWithBody opts body = makeAff \cb -> do
  let cb' res = cb $ Right res
  req <- C.request opts cb'
  let writable = C.requestAsStream req
  void $ writeString writable UTF8 body $ pure unit
  end writable $ pure unit
  pure nonCanceler
