#!/bin/sh
 
. ./00_init_paths.sh  || die "00_init_paths.sh expected";
 
# TODO : 
#   - AM : quinphones, MLP ....
#   - LM : perplexity on dev, native 4g, rnnLM
 
# monophones ---> ???

pushd /home/tan/kaldi/swahili
steps/train_mono.sh  --nj 4 data/train lang/ exp/system1/mono
utils/mkgraph.sh --mono lang/ exp/system1/mono exp/system1/mono/graph
steps/decode.sh --nj 4  exp/system1/mono/graph  data/test exp/system1/mono/decode_test
popd
