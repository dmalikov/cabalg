module Args where

import           Control.Arrow (second)

data Action
  = Help
  | Version
  | Install [String] (Maybe String)


fromArgs :: [String] -> Action
fromArgs [x] | x `elem` ["--help", "--usage", "-h"] = Help
fromArgs ["--version"] = Version
fromArgs x = uncurry Install . second flags . span (/= "--") $ x
 where
  flags [] = Nothing
  flags ["--"] = Nothing
  flags (_:xs) = Just $ unwords xs


printHelp :: IO ()
printHelp = putStrLn $ unlines
  [ "cabalg is an alias for installing cabal package from git source repository."
  , ""
  , "Usage:"
  , "    $> cabalg <repo1> ... <repoN> [-- <cabal-install args>]"
  , ""
  , "Example:"
  , "    $> cabalg https://github.com/biegunka/biegunka@f524f97"
  ]

