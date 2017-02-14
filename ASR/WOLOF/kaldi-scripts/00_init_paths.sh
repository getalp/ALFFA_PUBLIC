#!/bin/sh

###
## Useful variables used by kaldi-scripts/ directory
#

WORK_DIR=`pwd`
DATA_DIR=$WORK_DIR/data
LEXICON=$DATA_DIR/local/dict/lexicon.txt

## /!\ Path to modify /!\ 
# Put the path mapping to your kaldi installation
KALDI_DIR=$HOME/kaldi-trunk

PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/lmbin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$WORK_DIR/utils:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:$KALDI_DIR/src/nnet-cpubin/:

export PATH
export LC_ALL=C