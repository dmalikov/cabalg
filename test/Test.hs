module Main where

import           System.Directory
import           System.Exit
import           System.FilePath
import           System.Process

main :: IO ()
main = do
  throwsExitCode

throwsExitCode :: IO ()
throwsExitCode = do
  currentDir <- getCurrentDirectory
  exec <- findExecutableCabalg currentDir
  case exec of
    Nothing -> error "unable to find cabalg executable in dist/build"
    Just cabalg -> do
      (exitCode, _, _) <- readProcessWithExitCode cabalg ["https://github.com/dmalikov/cabalg@broken"] []
      case exitCode of
        ExitSuccess -> error "cabalg masks cabal failure, proper exit code was not thrown"
        _ -> setCurrentDirectory currentDir

findExecutableCabalg :: FilePath -> IO (Maybe FilePath)
findExecutableCabalg dir = do
  exists <- doesFileExist executable'
  if (exists)
    then return $ Just $ executable'
    else return Nothing
 where
  executable' = dir </> "dist" </> "build" </> "cabalg" </> "cabalg"
