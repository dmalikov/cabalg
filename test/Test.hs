{-# LANGUAGE QuasiQuotes #-}
module Main where

import System.Command.QQ

main :: IO ()
main = do
  [sh_|
    mkdir -p testdir
    cd testdir
    git clone https://github.com/dmalikov/dotfiles
    cabalg https://github.com/biegunka/biegunka@develop -- dotfiles/biegunka/dotfiles.cabal
    cd ../
  |]

