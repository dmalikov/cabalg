[![Hackage](https://budueba.com/hackage/cabalg)](http://hackage.haskell.org/package/cabalg)
[![Build Status](https://secure.travis-ci.org/dmalikov/cabalg.png?branch=master)](http://travis-ci.org/dmalikov/cabalg)

`cabalg` is an alias for installing cabal package from git source repository.

Nowadays maintainers are too lazy to upload new versions of packages on hackage as fast as you think they do. Thus to build your own package in travis depending on this non-uploaded one you need to fetch it from github repo and build them together. `.travis.yml` becomes too noisy.

I.e. we have `biegunka` package which depends on `temporary` and `acid-state` packages not uploaded on hackage yet:
```
- git clone https://github.com/supki/temporary
- git clone https://github.com/acid-state/acid-state
- cabal install temporary/temporary.cabal acid-state/acid-state.cabal biegunka.cabal
```

These routines could be rewritten with `cabalg` (btw `cabalg` is not available on travis worker by default, hence you need to install it manually):
```
- cabalg https://github.com/supki/temporary https://github.com/acid-state/acid-state -- biegunka.cabal
```

It also supports arbitrary git revisions mentioning like
```
$> cabalg https://github.com/biegunka/biegunka@f524f97
```

Necessary arguments could be passed to `cabal install` with `--` delimiter like

```
$> cabalg <repo1> ... <repoN> [-- <cabal-install args>]
```

Please notice, that `--single-branch` flag comes with [git-1.7.10](https://lkml.org/lkml/2012/3/28/418) and later, so you probably want to have it.

It's supposed to be Windows-compatible.
