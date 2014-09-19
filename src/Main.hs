import           Control.Applicative
import           Control.Exception
import           Control.Monad
import           Data.Foldable
import           Data.List
import           Data.Maybe
import           Data.Traversable
import           System.Directory
import           System.Environment
import           System.Exit
import           System.FilePath
import           System.IO.Error
import           System.Process

import           Cabalg.Args
import           Cabalg.Git
import           Cabalg.Version
import           System.Directory.NonExistent


main :: IO ()
main = do
  action <- fromString <$> getArgs
  case action of
    Help -> printHelp
    Version -> putStrLn version
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
  (_, _, _, procHandle) <- createProcess $ proc "cabal" $ "install" : cabalFiles ++ words (fromMaybe "" args)
  exitCode <- waitForProcess procHandle
  case exitCode of
    ExitSuccess -> return ()
    ExitFailure _ -> exitFailure


-- | Compute the repository name from the URL
--
-- >>> repoName "https://github.com/dmalikov/cabalg"
-- "cabalg"
--
-- >>> repoName "https://github.com/dmalikov/cabalg@master"
-- "cabalg"
--
-- >>> repoName "git://github.com/dmalikov/cabalg"
-- "cabalg"
repoName :: String -> String
repoName = takeWhile (/= '@') . lastSplitOn '/'
 where
  lastSplitOn c = go
   where
    go xs = case break (== c) xs of
      (ys , [])      -> ys
      (_  , _ : xs') -> go xs'


findCabalFile :: FilePath -> IO (Maybe FilePath)
findCabalFile path = ((path </>) `fmap`) `fmap` Data.List.find (".cabal" `isSuffixOf`) `fmap` getDirectoryContents path
