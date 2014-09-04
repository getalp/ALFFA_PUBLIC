#!/bin/sh
# decoding stage will present two results ; decode_test_si and decode_test in tri3b folder. decode_test_si gives results with SAT and decode_test gives results with SAT and fMLLR applied 

. ./00_init_paths.sh  || die "00_init_paths.sh expected";


# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM
# SAT+FMLLR ---> ????

#steps/align_si.sh  --nj 4  data/train lang exp/system1/tri2a exp/system1/tri2a_ali
#steps/train_sat.sh 3200 30000 data/train lang exp/system1/tri2a_ali exp/system1/tri3b
utils/mkgraph.sh lang  exp/system1/tri3b exp/system1/tri3b/graph
steps/decode_fmllr.sh --nj 4  exp/system1/tri3b/graph  data/test exp/system1/tri3b/decode_test

#steps/align_fmllr.sh --nj 4 data/train lang exp/system1/tri3b exp/system1/tri3b_ali


