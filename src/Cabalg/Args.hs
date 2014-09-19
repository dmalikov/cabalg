module Cabalg.Args where

import           Control.Arrow (second)

data Action
  = Help
  | Version
  | Install [String] (Maybe String)
    deriving (Eq, Show)


-- | Deserialize cabalg action
--
-- >>> fromString ["--version"]
-- Version
--
-- >>> fromString ["--help"]
-- Help
--
-- >>> fromString ["--usage"]
-- Help
--
-- >>> fromString ["-h"]
-- Help
--
-- >>> fromString ["https://url"]
-- Install ["https://url"] Nothing
--
-- >>> fromString ["https://url", "--", "--flags"]
-- Install ["https://url"] (Just "--flags")
fromString :: [String] -> Action
fromString [x] | x `elem` ["--help", "--usage", "-h"] = Help
fromString ["--version"] = Version
fromString x = uncurry Install . second flags . span (/= "--") $ x
 where
  flags [] = Nothing
  flags ["--"] = Nothing
  flags (_:xs) = Just $ unwords xs


printHelp :: IO ()
printHelp = putStrLn $ unlines
  [ "cabalg is an alias for installing cabal package from git source repository."
  , ""
  , "Usage:"
  , "    $ cabalg [--version | [repository url...] [-- [cabal-install args...]]]"
  , ""
  , "Example:"
  , "    $ cabalg https://github.com/biegunka/biegunka@f524f97"
  ]

