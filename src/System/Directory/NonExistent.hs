module System.Directory.NonExistent where

import           System.Directory
import           System.FilePath

-- | create non existent directory appending a number to the end of the name
createNonExistentDirectory :: FilePath -> String -> IO FilePath
createNonExistentDirectory currentDir dirname = do
  newDir <- generateNonExistentDirectory dirname Nothing
  createDirectory newDir
  return newDir
    where
      generateNonExistentDirectory :: FilePath -> Maybe Int -> IO FilePath
      generateNonExistentDirectory d suffix = let fullDirName = currentDir </> d ++ maybe "" show suffix in do
        exist <- doesDirectoryExist fullDirName
        if exist
          then generateNonExistentDirectory d $ return $ maybe 1 (+ 1) suffix
          else return fullDirName

