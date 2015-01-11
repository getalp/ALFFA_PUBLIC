#!/bin/sh


#. ./path.sh
. ./00_init_paths.sh  || die "00_init_paths.sh expected";


# LDA+MLLT

steps/align_si.sh  --nj 4  data/train data/lang exp/system1/tri2a exp/system1/tri2a_ali
steps/train_lda_mllt.sh   --splice-opts "--left-context=3 --right-context=3"   2000 20000 data/train data/lang  exp/system1/tri2a_ali exp/system1/tri2b
utils/mkgraph.sh data/lang  exp/system1/tri2b exp/system1/tri2b/graph
steps/decode.sh --nj 4  exp/system1/tri2b/graph  data/test exp/system1/tri2b/decode_test

echo -e "LDA+MLLT training done.\n"
