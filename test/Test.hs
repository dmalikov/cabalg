module Main where

import           Control.Monad
import           System.Directory
import           System.FilePath
import           System.Process


main :: IO ()
main = do
  currentDir <- getCurrentDirectory
  exec <- findExecutableCabalg currentDir
  case exec of
    Nothing -> error "unable to find cabalg executable in dist/build"
    Just cabalg -> do
      void $ readProcess cabalg ["https://github.com/dmalikov/dotfiles@master", "https://github.com/biegunka/biegunka@develop"] []
      setCurrentDirectory currentDir


findExecutableCabalg :: FilePath -> IO (Maybe FilePath)
findExecutableCabalg dir = do
  exists <- doesFileExist executable'
  if (exists)
    then return $ Just $ executable'
    else return Nothing
 where
  executable' = dir </> "dist" </> "build" </> "cabalg" </> "cabalg"
