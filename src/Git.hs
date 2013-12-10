{-# LANGUAGE ScopedTypeVariables #-}
module Git where

import           Data.Maybe      (fromMaybe)
import           System.Process  (callProcess)

-- | git clone
clone :: String       -- | url
      -> Maybe String -- | branch name
      -> FilePath     -- | directory where repository will be clone to
      -> IO ()
clone url maybe_branch dir =
  callProcess "git" ["clone"
    , "--branch", fromMaybe "master" maybe_branch
    , "--single-branch"
    , "--depth=1"
    , "--quiet"
    , url
    , dir]
