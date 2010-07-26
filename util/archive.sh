#!/bin/bash -e

cd "$( dirname $( dirname $0 ) )"
git archive --prefix=coseis/ -o coseis.tar HEAD
git log -100 > changelog
tar -s,^,coseis/, -rf coseis.tar changelog
gzip -c coseis.tar > download/coseis.tgz
rm changelog coseis.tar

