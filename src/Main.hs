{-# LANGUAGE NoOverloadedStrings, ScopedTypeVariables #-}
import           Control.Applicative
import           Data.Maybe
import           Options.Applicative
import           System.Directory
import           System.FilePath.Posix
import           System.Process
import           Text.Regex.PCRE

type GitPath = String
type GitBranch = String

git_clone :: GitPath -> Maybe GitBranch -> IO String
git_clone path maybe_branch = do
  callProcess "git" ["clone", "--branch", branch, "--single-branch", "--depth=1", "--quiet", path, dir]
  return dir
 where
  branch = fromMaybe "master" maybe_branch
  dir :: String = path =~ "(?<=/).*(?=.git)"

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

data Configuration = Configuration { _git_path :: String, _branch :: Maybe String }

opt_parser :: Parser Configuration
opt_parser = Configuration
  <$> argument str (metavar "REPO")
  <*> optional (strOption (long "branch" <> short 'b'))

install :: Configuration -> IO ()
install (Configuration { _git_path = path, _branch = b }) = do
  dir <- git_clone path b
  sandbox_dir <- try_get_sandbox_dir
  cd dir
  case sandbox_dir of
    Just dir' -> link_to_sandbox dir'
    Nothing   -> return ()
  callProcess "cabal" ["install"]
  setCurrentDirectory . takeDirectory =<< getCurrentDirectory
  removeDirectoryRecursive dir

main :: IO ()
main = execParser opts >>= install
  where opts = info (helper <*> opt_parser) $ fullDesc <>
          progDesc "Install cabal package from git to cabal globally or in sandbox if it exists"

