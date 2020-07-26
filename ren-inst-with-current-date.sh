#!/usr/bin/bash

set -euo pipefail

mv -i INSTPRIV.tgz INSTPRIV-$(date +%F).tgz
mv -i INSTPUB.tgz INSTPUB-$(date +%F).tgz

