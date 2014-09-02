import Control.Applicative
import Control.Monad
import Data.List
import Data.Maybe
import Data.Version (showVersion)
import Paths_cabalg (version)
import System.Directory
import System.Environment
import System.FilePath
import System.Process

import Args
import Git
import System.Directory.NonExistent


main :: IO ()
main = do
  action <- fromArgs <$> getArgs
  case action of
    Help -> printHelp
    Version -> putStrLn $ showVersion version
    Install repos args -> do
      cabalFiles <- mapM fetch repos
      cabalInstall (catMaybes cabalFiles) args


fetch :: String -> IO (Maybe FilePath)
fetch urlAndMaybeRevision = do
  currentDir <- getCurrentDirectory
  newDir <- createNonExistentDirectory currentDir ("cabalg_" ++ repoName urlAndMaybeRevision)
  case maybeRevision of
    Just revision -> cloneRevision url revision newDir
    Nothing -> clone url newDir
  findCabalFile newDir
    where
      maybeRevision = case dropWhile (/= '@') urlAndMaybeRevision of
        '@':x -> Just x
        _ -> Nothing
      url = takeWhile (/= '@') urlAndMaybeRevision


cabalInstall :: [String] -> Maybe String -> IO ()
cabalInstall cabalFiles args = do
  let process = proc "cabal" ("install" : cabalFiles ++ words (fromMaybe "" args))
  (_, _, _, procHandle) <- createProcess process
  void $ waitForProcess procHandle


repoName :: String -> String
repoName = takeWhile (/= '@') . lastSplitOn '/'
  where lastSplitOn :: Eq a => a -> [a] -> [a]
        lastSplitOn c = go []
          where
            go acc (x:xs) | x == c = go [] xs
                          | otherwise = go (acc ++ [x]) xs
            go acc [] = acc


findCabalFile :: FilePath -> IO (Maybe FilePath)
findCabalFile path = ((path </>) `fmap`) `fmap` find (".cabal" `isSuffixOf`) `fmap` getDirectoryContents path
