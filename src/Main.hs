{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
import           Control.Applicative
import           Control.Arrow        (second)
import           Control.Monad
import           Data.List.Split      (splitOn)
import           Data.Maybe           (catMaybes, fromMaybe, listToMaybe)
import           System.Directory     (createDirectory, getCurrentDirectory)
import           System.Environment
import           System.FilePath
import           System.FilePath.Find
import           System.Process       (callProcess)
import           System.Random

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
fetch urlAndMaybeRevision = do
  currentDir <- getCurrentDirectory
  cabalDir <- (currentDir </>) . addName <$> genstr
  createDirectory cabalDir
  case maybeRevision of
    Just revision -> cloneRevision url revision cabalDir
    Nothing -> clone url cabalDir
  listToMaybe <$> find always (extension ==? ".cabal") cabalDir
    where
      maybeRevision = listToMaybe . tail . splitOn "@" $ urlAndMaybeRevision
      url = head $ splitOn "@" urlAndMaybeRevision
      genstr = liftM (take 10 . randomRs ('a','z')) newStdGen
      addName = (("cabalg_" ++ last (splitOn "/" url)) ++) . ('_' :)

cabalInstall :: [String] -> Maybe String -> IO ()
cabalInstall cabalFiles args = callProcess "cabal" $ "install" : cabalFiles ++ words (fromMaybe "" args)

