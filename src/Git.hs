module Git where

import           System.Directory
import           System.FilePath  ()
import           System.Process

-- | git clone "master" branch
clone :: String       -- ^ url
      -> FilePath     -- ^ directory where repository will be cloned to
      -> IO ()
clone url dir = putStr =<< readProcess "git"
  [ "clone"
  , "--single-branch"
  , "--depth=1"
  , url
  , dir] []

-- | git clone and checkout particular revision (could be much slower than 'clone')
cloneRevision :: String   -- ^ url
              -> String   -- ^ revision
              -> FilePath -- ^ directory where repository will be cloned to
              -> IO ()
cloneRevision url revision dir = do
  putStr =<< readProcess "git" [ "clone", url, dir ] []
  currentDir <- getCurrentDirectory
  setCurrentDirectory dir
  putStr =<< readProcess "git" [ "checkout", revision, "--force" ] []
  setCurrentDirectory currentDir
