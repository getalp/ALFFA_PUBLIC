#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM


# triphones

#steps/align_si.sh --boost-silence 1.25 --nj 4  data/train lang exp/system1/mono exp/system1/mono_ali
#steps/train_deltas.sh --boost-silence 1.25  3200 30000 data/train lang exp/system1/mono_ali exp/system1/tri1
utils/mkgraph.sh lang  exp/system1/tri1 exp/system1/tri1/graph
steps/decode.sh --nj 4  exp/system1/tri1/graph  data/test exp/system1/tri1/decode_test

# triphones + delta delta

#steps/align_si.sh  --nj 4  data/train lang exp/system1/tri1 exp/system1/tri1_ali
#steps/train_deltas.sh  3200 30000 data/train lang exp/system1/tri1_ali exp/system1/tri2a
utils/mkgraph.sh lang/  exp/system1/tri2a exp/system1/tri2a/graph
steps/decode.sh --nj 4  exp/system1/tri2a/graph  data/test exp/system1/tri2a/decode_test

