0.2.8
=====

  * Respect `$TMPDIR` and `$TEMP` environment variables

0.2.7
=====

  * Add `--help` and `--version` command line options

  * Bug fixed: download the default upstream branch unless another one is explicitly provided
    https://github.com/dmalikov/cabalg/issues/5


0.2.6
=====

  * Display progress incrementally during install by allowing standard handles to inherit (@cpennington)

0.2.5
=====

  * Print cabal logs to the output

0.2.4
=====

  * Bug fixed: internal `git checkout` producing redundant copy of git repository
    https://github.com/dmalikov/cabalg/issues/3


0.2.3
=====

  * All non-base dependencies are dropped
  * `7.2`, `7.4`, `7.6`, `7.8` are supported

0.2.2
=====

  * Select `*.cabal` files found only with depth 1

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
