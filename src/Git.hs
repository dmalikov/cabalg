module Git where

import Control.Monad
import System.FilePath
import System.Process

-- | git clone "master" branch
clone :: String       -- | url
      -> FilePath     -- | directory where repository will be cloned to
      -> IO ()
clone url dir = void $ readProcess "git"
  [ "clone"
  , "--branch", "master"
  , "--single-branch"
  , "--depth=1"
  , "--quiet"
  , url
  , dir] []

-- | git clone and checkout in particular revision (could be much slower than 'clone')
cloneRevision :: String   -- | url
              -> String   -- | revision
              -> FilePath -- | directory where repository will be cloned to
              -> IO ()
cloneRevision url revision dir = do
  void $ readProcess "git" [ "clone", url, dir ] []
  void $ readProcess "git" [ "--git-dir", dir </> ".git", "checkout", revision, "--force", "--quiet" ] []

