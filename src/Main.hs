import           Control.Applicative
import           Control.Exception
import           Control.Monad
import           Data.Foldable
import           Data.List
import           Data.Maybe
import           Data.Traversable
import           Data.Version                 (showVersion)
import           Paths_cabalg                 (version)
import           System.Directory
import           System.Environment
import           System.FilePath
import           System.IO.Error
import           System.Process

import           Args
import           Git
import           System.Directory.NonExistent


main :: IO ()
main = do
  action <- fromArgs <$> getArgs
  case action of
    Help -> printHelp
    Version -> putStrLn $ showVersion version
    Install repos args -> do
      cabalFiles <- Data.Traversable.mapM fetch repos
      cabalInstall (catMaybes cabalFiles) args


fetch :: String -> IO (Maybe FilePath)
fetch urlAndMaybeRevision = do
  dir <-  getWorkingDirectory
  newDir <- createNonExistentDirectory dir ("cabalg_" ++ repoName urlAndMaybeRevision)
  case maybeRevision of
    Just revision -> cloneRevision url revision newDir
    Nothing -> clone url newDir
  findCabalFile newDir
    where
      maybeRevision = case dropWhile (/= '@') urlAndMaybeRevision of
        '@':x -> Just x
        _ -> Nothing
      url = takeWhile (/= '@') urlAndMaybeRevision


getWorkingDirectory :: IO FilePath
getWorkingDirectory =
  liftM2 fromMaybe getCurrentDirectory . fmap Data.Foldable.msum . traverse lookupEnv' $ ["TMPDIR", "TEMP"]


lookupEnv' :: String -> IO (Maybe String)
lookupEnv' var = do
  fmap eitherToMaybe . tryJust (guard . isDoesNotExistError) $ getEnv var
 where
  eitherToMaybe (Left  _) = Nothing
  eitherToMaybe (Right x) = Just x


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
findCabalFile path = ((path </>) `fmap`) `fmap` Data.List.find (".cabal" `isSuffixOf`) `fmap` getDirectoryContents path
