#!/bin/bash

. ./kaldi-scripts/00_init_paths.sh || die "00_init_paths.sh expected";

if [ ! -L utils ]; then ln -s $KALDI_DIR/egs/wsj/s5/utils; fi
if [ ! -L conf ]; then ln -s $KALDI_DIR/egs/wsj/s5/conf; fi
if [ ! -L steps ]; then ln -s $KALDI_DIR/egs/wsj/s5/steps; fi
if [ ! -L local ]; then ln -s $KALDI_DIR/egs/wsj/s5/local; fi
if [ ! -L cmd.sh ]; then ln -s $KALDI_DIR/egs/wsj/s5/cmd.sh; fi

