import Control.Applicative
import Control.Arrow
import Control.Monad
import Data.List
import Data.Maybe
import System.Directory
import System.Environment
import System.FilePath
import System.Process

import Git
import System.Directory.NonExistent


main :: IO ()
main = do
  (repos, args) <- reposAndArgs <$> getArgs
  cabalFiles <- mapM fetch repos
  cabalInstall (catMaybes cabalFiles) args


reposAndArgs :: [String] -> ([String], Maybe String)
reposAndArgs = second flags . span (/= "--")
 where
  flags [] = Nothing
  flags ["--"] = Nothing
  flags (_:xs) = Just $ unwords xs

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
