{-# OPTIONS_GHC -Wno-orphans #-}

module Arbitrary where

import Data.Char
import Data.Maybe
import System.OsString
import System.OsString.Internal.Types
import qualified System.OsString.Posix as Posix
import qualified System.OsString.Windows as Windows

import Test.QuickCheck.Arbitrary
import Test.QuickCheck.Checkers
import Test.QuickCheck.Gen


newtype NonNullString = NonNullString { nonNullString :: String }
  deriving Show

instance Arbitrary OsString where
  arbitrary = fmap fromJust $ toOsStringUtf <$> listOf filepathChar

instance EqProp OsString where
  (=-=) = eq

instance Arbitrary PosixString where
  arbitrary = fmap fromJust $ Posix.toPlatformStringUtf <$> listOf filepathChar

instance EqProp PosixString where
  (=-=) = eq

instance Arbitrary WindowsString where
  arbitrary = fmap fromJust $ Windows.toPlatformStringUtf <$> listOf filepathChar

instance EqProp WindowsString where
  (=-=) = eq

instance Arbitrary NonNullString where
  arbitrary = NonNullString <$> listOf filepathChar


filepathChar :: Gen Char
filepathChar = arbitraryBoundedEnum `suchThat` (\c -> not (isNull c) && isValidUnicode c)
 where
  isNull = (== '\NUL')
  isValidUnicode c = case generalCategory c of
      Surrogate -> False
      NotAssigned -> False
      _ -> True

