module Bucketchain.Stream where

import Prelude

import Data.Either (Either(..))
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Ref (modify_, new, read)
import Node.Encoding (Encoding(..))
import Node.Stream (Readable, onDataString, onEnd, onError)

-- | Convert a readable stream to a string asynchronously.
convertToString :: forall r. Readable r -> Aff String
convertToString readable = makeAff \cb -> do
  ref <- new ""
  onDataString readable UTF8 \chunk -> modify_ (flip append chunk) ref
  onError readable \err -> cb $ Left err
  onEnd readable $ Right <$> read ref >>= cb
  pure nonCanceler
