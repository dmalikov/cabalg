{-# LANGUAGE ScopedTypeVariables #-}
module Git where

import           System.FilePath
import           System.Process  (callProcess)

-- | git clone "master" branch
clone :: String       -- | url
      -> FilePath     -- | directory where repository will be cloned to
      -> IO ()
clone url dir =
  callProcess "git"
    [ "clone"
    , "--branch", "master"
    , "--single-branch"
    , "--depth=1"
    , "--quiet"
    , url
    , dir]

-- | git clone and checkout in particular revision (could be much slower than 'clone')
cloneRevision :: String   -- | url
              -> String   -- | revision
              -> FilePath -- | directory where repository will be cloned to
              -> IO ()
cloneRevision url revision dir = do
  callProcess "git" [ "clone", url, dir ]
  callProcess "git" [ "--git-dir", dir </> ".git", "checkout", revision, "--quiet" ]
