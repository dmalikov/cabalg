{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
import           Control.Applicative
import           Control.Arrow        (second)
import           Data.List.Split      (splitOn)
import           Data.Maybe           (catMaybes, fromMaybe, listToMaybe)
import           System.Directory     (getCurrentDirectory)
import           System.Environment
import           System.FilePath.Find
import           System.IO.Temp       (createTempDirectory)
import           System.Process       (callProcess)

import           Git


main :: IO ()
main = do
  (repos, args) <- reposAndArgs <$> getArgs
  cabalFiles :: [Maybe FilePath] <- mapM fetch repos
  cabalInstall (catMaybes cabalFiles) args


reposAndArgs :: [String] -> ([String], Maybe String)
reposAndArgs = second flags . span (/= "--")
 where
  flags [] = Nothing
  flags ["--"] = Nothing
  flags (_:xs) = Just $ unwords xs

fetch :: String -> IO (Maybe FilePath)
fetch url = do
  current_dir <- getCurrentDirectory
  cabal_dir <- createTempDirectory current_dir ("cabalg_" ++ last (splitOn "/" url) ++ "X")
  clone url Nothing cabal_dir
  listToMaybe <$> find always (extension ==? ".cabal") cabal_dir

cabalInstall :: [String] -> Maybe String -> IO ()
cabalInstall cabalFiles args = callProcess "cabal" $ "install" : cabalFiles ++ words (fromMaybe "" args)

