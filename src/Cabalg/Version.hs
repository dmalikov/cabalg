module Cabalg.Version where

import           Data.Version (showVersion)
import           Paths_cabalg (version)

version :: String
version = showVersion Paths_cabalg.version
