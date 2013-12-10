{-# LANGUAGE NoOverloadedStrings #-}
import           Options.Applicative
import           System.Directory    (getCurrentDirectory, getTemporaryDirectory, setCurrentDirectory)
import           System.IO.Temp      (withTempDirectory)
import           System.Process      (callProcess)

import           Git
import           Sandbox


main :: IO ()
main = execParser opts >>= install
  where opts = info (helper <*> opt_parser) $ fullDesc <>
          progDesc "Install cabal package from git to cabal globally or in sandbox if it exists"


data Configuration = Configuration { _git_url :: String, _branch :: Maybe String }

install :: Configuration -> IO ()
install (Configuration { _git_url = url, _branch = branch }) = do
  back <- getCurrentDirectory
  temp_dir <- getTemporaryDirectory
  withTempDirectory temp_dir "cabalg_X" $ \dir -> do
    clone url branch dir
    sandbox_dir <- try_get_sandbox_dir back
    setCurrentDirectory dir
    case sandbox_dir of
      Just dir' -> link_to_sandbox dir'
      Nothing   -> return ()
    callProcess "cabal" ["install"]
  setCurrentDirectory back

opt_parser :: Parser Configuration
opt_parser = Configuration
  <$> argument str (metavar "URL")
  <*> optional (strOption (long "branch" <> short 'b'))
