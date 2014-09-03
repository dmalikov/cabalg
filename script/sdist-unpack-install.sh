#!/bin/bash
set -o pipefail

tmp=`mktemp --directory`
filename=`cabal sdist | grep -P -o "(?<=created: dist/).*"`

cp ./dist/${filename} ${tmp}/
cd ${tmp}
tar --strip-components=1 --extract --file ${filename}

cabal sandbox init
cabal install
