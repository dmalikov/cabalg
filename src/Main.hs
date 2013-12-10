{-# LANGUAGE NoOverloadedStrings, ScopedTypeVariables #-}
import           Control.Applicative
import           Options.Applicative
import           System.Directory
import           System.FilePath.Posix
import           System.IO.Temp
import           System.Process

import           Git


try_get_sandbox_dir :: IO (Maybe FilePath)
try_get_sandbox_dir = do
  dir <- getCurrentDirectory
  let sandbox_dir = dir </> ".cabal-sandbox"
  exist <- doesDirectoryExist sandbox_dir
  return $ if exist
    then Just sandbox_dir
    else Nothing

cd :: String -> IO ()
cd dir = do
  current <- getCurrentDirectory
  setCurrentDirectory (current </> dir)

link_to_sandbox :: FilePath -> IO ()
link_to_sandbox sandbox_dir = callProcess "cabal" ["sandbox", "init", "--sandbox", sandbox_dir]

with_temp_dir :: (FilePath -> IO ()) -> IO ()
with_temp_dir f = do
  temp_dir <- getTemporaryDirectory
  withTempDirectory temp_dir "cabalg_X" f


install :: Configuration -> IO ()
install (Configuration { _git_url = url, _branch = branch }) = do
  back <- getCurrentDirectory
  with_temp_dir $ \dir -> do
    clone url branch dir
    sandbox_dir <- try_get_sandbox_dir
    cd dir
    case sandbox_dir of
      Just dir' -> link_to_sandbox dir'
      Nothing   -> return ()
    callProcess "cabal" ["install"]
  setCurrentDirectory back

data Configuration = Configuration { _git_url :: String, _branch :: Maybe String }

opt_parser :: Parser Configuration
opt_parser = Configuration
  <$> argument str (metavar "REPO")
  <*> optional (strOption (long "branch" <> short 'b'))

main :: IO ()
main = execParser opts >>= install
  where opts = info (helper <*> opt_parser) $ fullDesc <>
          progDesc "Install cabal package from git to cabal globally or in sandbox if it exists"

