#!/bin/sh

export NVIM_QT='true'
nvim-qt --geometry 850x880 $@ >/dev/null 2>&1
