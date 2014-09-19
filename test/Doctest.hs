module Main (main) where

import Test.DocTest (doctest)

main :: IO ()
main = doctest ["-i src", "-i dist/build/autogen", "src/Cabalg/Args.hs", "src/Main.hs"]
