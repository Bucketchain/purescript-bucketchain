module Bucketchain.ResponseBody
  ( ResponseBody
  , toReadable
  , fromReadable
  , maybeToBody
  , body
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Node.Stream (Readable)
import Unsafe.Coerce (unsafeCoerce)

-- | The type of a response body stream.
foreign import data ResponseBody :: Type

-- | Convert a response body stream to a Readable stream.
toReadable :: ResponseBody -> Readable ()
toReadable = unsafeCoerce

-- | Convert a Readable stream to a response body stream.
fromReadable :: Readable () -> ResponseBody
fromReadable = unsafeCoerce

-- | Get a response body stream certainly from `Maybe ResponseBody`.
maybeToBody :: Maybe ResponseBody -> Effect ResponseBody
maybeToBody (Just x) = pure x
maybeToBody Nothing = empty

-- | Create a response body stream.
foreign import body :: String -> Effect ResponseBody

foreign import empty :: Effect ResponseBody
