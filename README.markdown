[![Hackage](https://budueba.com/hackage/cabalg)](http://hackage.haskell.org/package/cabalg)
[![Build Status](https://secure.travis-ci.org/dmalikov/cabalg.png?branch=master)](http://travis-ci.org/dmalikov/cabalg)

`cabalg` is an alias for installing cabal package from a git source repository.

E.g.

```
$ git clone https://github.com/author/foo
$ git clone https://github.com/author/bar
$ cabal install foo/foo.cabal bar/bar.cabal baz.cabal
```

could be abbreviated by

```
$ cabalg https://github.com/author/foo https://github.com/author/bar -- baz.cabal
```

It also supports arbitrary git revisions mentioning like
```
$ cabalg https://github.com/baz/quux@f524f97
```

Necessary arguments could be passed to `cabal install` with `--` delimiter like

```
$ cabalg <repo1> ... <repoN> [-- <cabal-install args>]
```

Please notice that `--single-branch` flag comes with [git-1.7.10](https://lkml.org/lkml/2012/3/28/418) and later, so you probably want to have it.

It's supposed to be Windows-compatible.
