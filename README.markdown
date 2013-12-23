[![Hackage](https://budueba.com/hackage/cabalg)](http://hackage.haskell.org/package/cabalg)
[![Build Status](https://secure.travis-ci.org/dmalikov/cabalg.png?branch=master)](http://travis-ci.org/dmalikov/cabalg)

`cabalg` is an alias for installing cabal package from git source repository.

I.e.

```
$> cabalg git://github.com/biegunka/biegunka.git --branch=develop
```

is just a shorthand for

```
$> create-dir /temp/directory
$> git clone --branch develop --single-branch --depth=1 --quiet git://github.com/biegunka/biegunka.git /temp/directory
$> change-dir /temp/directory
$> cabal install
$> change-dir-back
$> remove-dir /temp/directory
```

If current directory is cabal-sandbox'ed, `cabalg` will attach the given repo to it.

Also notice, that `--single-branch` flag comes with [git-1.7.10](https://lkml.org/lkml/2012/3/28/418) and later, so you probably want to have it.
