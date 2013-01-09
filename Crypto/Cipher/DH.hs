{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- |
-- Module      : Crypto.Cipher.DH
-- License     : BSD-style
-- Maintainer  : Vincent Hanquez <vincent@snarc.org>
-- Stability   : experimental
-- Portability : Good
--
module Crypto.Cipher.DH {-# DEPRECATED "Use crypto-pubkey Crypto.PubKey.DH" #-}
	( Params
	, PublicNumber
	, PrivateNumber
	, SharedKey
	, generateParams
	, generatePrivate
	, generatePublic
	, getShared
	) where

import Number.ModArithmetic (exponantiation)
import Number.Prime (generateSafePrime)
import Number.Generate (generateOfSize)
import Crypto.Types.PubKey.DH
import Crypto.Random
import Control.Arrow (first)

-- | generate params from a specific generator (2 or 5 are common values)
-- we generate a safe prime (a prime number of the form 2p+1 where p is also prime)
generateParams :: CryptoRandomGen g => g -> Int -> Integer -> Either GenError (Params, g)
generateParams rng bits generator =
	either Left (Right . first (\p -> (p, generator))) $ generateSafePrime rng bits

-- | generate a private number with no specific property
-- this number is usually called X in DH text.
generatePrivate :: CryptoRandomGen g => g -> Int -> Either GenError (PrivateNumber, g)
generatePrivate rng bits = either Left (Right . first PrivateNumber) $ generateOfSize rng bits

-- | generate a public number that is for the other party benefits.
-- this number is usually called Y in DH text.
generatePublic :: Params -> PrivateNumber -> PublicNumber
generatePublic (p,g) (PrivateNumber x) = PublicNumber $ exponantiation g x p

-- | generate a shared key using our private number and the other party public number
getShared :: Params -> PrivateNumber -> PublicNumber -> SharedKey
getShared (p,_) (PrivateNumber x) (PublicNumber y) = SharedKey $ exponantiation y x p
