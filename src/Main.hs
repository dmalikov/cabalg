{-# LANGUAGE NoOverloadedStrings, ScopedTypeVariables #-}

import           System.Directory
import           System.Environment
import           System.FilePath.Posix
import           System.Process
import           Text.Regex.PCRE

git_clone :: String -> IO String
git_clone repo = do
  callProcess "git" ["clone", "--depth=1", "--quiet", repo, dir]
  return dir
 where
  dir :: String = repo =~ "(?<=/).*(?=.git)"

try_get_sandbox_dir :: IO (Maybe FilePath)
try_get_sandbox_dir = do
  dir <- getCurrentDirectory
  let sandbox_dir = dir </> ".cabal-sandbox"
  exist <- doesDirectoryExist sandbox_dir
  return $ if exist
    then Just sandbox_dir
    else Nothing

cd :: String -> IO ()
cd dir = do
  current <- getCurrentDirectory
  setCurrentDirectory (current </> dir)

link_to_sandbox :: FilePath -> IO ()
link_to_sandbox sandbox_dir = callProcess "cabal" ["sandbox", "init", "--sandbox", sandbox_dir]

install :: IO ()
install = callProcess "cabal" ["install"]

main :: IO ()
main = do
  dir <- git_clone =<< head `fmap` getArgs
  sandbox_dir <- try_get_sandbox_dir
  cd dir
  case sandbox_dir of
    Just dir' -> link_to_sandbox dir'
    Nothing   -> return ()
  install
  setCurrentDirectory . takeDirectory =<< getCurrentDirectory
  removeDirectoryRecursive dir
