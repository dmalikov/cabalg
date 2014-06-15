module Main where

import System.Directory
import System.Process

import System.Directory.NonExistent

main :: IO ()
main = do
  currentDir <- getCurrentDirectory
  tmpDir <- createNonExistentDirectory currentDir "cabalgtest"
  setCurrentDirectory tmpDir
  callProcess "cabalg" ["https://github.com/dmalikov/dotfiles@master", "https://github.com/biegunka/biegunka@develop"]
  setCurrentDirectory currentDir
