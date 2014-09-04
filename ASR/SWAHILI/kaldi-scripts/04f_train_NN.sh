#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM

# Deep Learning

steps/nnet2/train_tanh.sh --mix-up 8000 --initial-learning-rate 0.01 --final-learning-rate 0.001 --num-hidden-layers 4 --hidden-layer-dim 1024 data/train lang exp/system1/tri3b_ali exp/system1/nnet5c || exit 1
  
steps/decode_nnet_cpu.sh --nj 6 --transform-dir exp/system1/tri3b/decode_dev exp/system1/tri3b/graph data/dev exp/system1/nnet5c/decode_dev
