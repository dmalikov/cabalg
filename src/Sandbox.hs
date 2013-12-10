module Sandbox
  ( try_get_sandbox_dir, link_to_sandbox
  ) where

import           System.Directory      (doesDirectoryExist)
import           System.FilePath.Posix ((</>))
import           System.Process        (callProcess)

try_get_sandbox_dir :: FilePath -> IO (Maybe FilePath)
try_get_sandbox_dir dir = do
  exist <- doesDirectoryExist sandbox_dir
  return $ if exist
    then Just sandbox_dir
    else Nothing
 where
  sandbox_dir = dir </> ".cabal-sandbox"


link_to_sandbox :: FilePath -> IO ()
link_to_sandbox sandbox_dir = callProcess "cabal" ["sandbox", "init", "--sandbox", sandbox_dir]
