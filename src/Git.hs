module Git where

import System.Directory
import System.FilePath()
import System.Process

-- | git clone "master" branch
clone :: String       -- ^ url
      -> FilePath     -- ^ directory where repository will be cloned to
      -> IO ()
clone url dir = putStrLn =<< readProcess "git"
  [ "clone"
  , "--branch", "master"
  , "--single-branch"
  , "--depth=1"
  , "--quiet"
  , url
  , dir] []

-- | git clone and checkout particular revision (could be much slower than 'clone')
cloneRevision :: String   -- ^ url
              -> String   -- ^ revision
              -> FilePath -- ^ directory where repository will be cloned to
              -> IO ()
cloneRevision url revision dir = do
  putStrLn =<< readProcess "git" [ "clone", url, dir ] []
  currentDir <- getCurrentDirectory
  setCurrentDirectory dir
  putStrLn =<< readProcess "git" [ "checkout", revision, "--force", "--quiet" ] []
  setCurrentDirectory currentDir

