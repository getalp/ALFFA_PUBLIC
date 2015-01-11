#!/bin/sh


DATA_DIR=$WORK_DIR/data
WORK_DIR=`pwd`
KALDI_DIR=/home/kaldi-trunk
LEXICON=$DATA_DIR/local/dict/lexicon.txt
EXP_DIR="test"
TRAIN_DIR="train"

PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst-1.2.10/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$WORK_DIR/utils:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:$KALDI_DIR/src/nnet-cpubin/:

export PATH
export LC_ALL=C
