#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM
# LDA+MLLT

steps/align_si.sh  --nj 4  data/train lang exp/system1/tri2a exp/system1/tri2a_ali
steps/train_lda_mllt.sh   --splice-opts "--left-context=3 --right-context=3"   2000 20000 data/train lang  exp/system1/tri2a_ali exp/system1/tri2b
utils/mkgraph.sh lang  exp/system1/tri2b exp/system1/tri2b/graph
steps/decode.sh --nj 4  exp/system1/tri2b/graph  data/test exp/system1/tri2b/decode_test

