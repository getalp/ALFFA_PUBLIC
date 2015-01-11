#!/bin/sh

#. ./path.sh
. ./00_init_paths.sh  || die "00_init_paths.sh expected";
 
# monophones

steps/train_mono.sh  --nj 4 data/train data/lang exp/system1/mono
utils/mkgraph.sh --mono data/lang exp/system1/mono exp/system1/mono/graph
steps/decode.sh --nj 4  exp/system1/mono/graph  data/test exp/system1/mono/decode_test

echo -e "Mono training done.\n"
