0.2.1
=====

  * Get rid of `temporary` dependency

0.2.0
=====

  * Remove cabal sandbox support

  * Handle multiple number of git repository at once

  * Cloning repo in a current directory

  * Cmd line arguments are interpreting like `<repo1> ... <repoN> [-- <cabal-install flags>]`

  * Remove `--branch <branch_name>` flag

  * Add syntax to mentioning revisions like `https://<repourl>@<revision>`

0.1.2
=====
  Initial version introduced:

  * Cloning repo into a temporary directory according to `System.FilePath.getTemporaryDirectory`

  * Cabal sandbox support
