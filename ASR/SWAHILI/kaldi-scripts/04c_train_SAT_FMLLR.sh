#!/bin/sh
# decoding stage will present two results ; decode_test_si and decode_test in tri3b folder. decode_test_si gives results with SAT and decode_test gives results with SAT and fMLLR applied 

#. ./path.sh
. ./00_init_paths.sh  || die "00_init_paths.sh expected";

# SAT+FMLLR

steps/align_si.sh  --nj 4 --use-graphs true data/train data/lang exp/system1/tri2b exp/system1/tri2b_ali
steps/train_sat.sh 2000 20000 data/train data/lang exp/system1/tri2b_ali exp/system1/tri3b 
utils/mkgraph.sh data/lang  exp/system1/tri3b exp/system1/tri3b/graph
steps/decode_fmllr.sh --nj 4  exp/system1/tri3b/graph  data/test exp/system1/tri3b/decode_test

steps/align_fmllr.sh --nj 4 data/train data/lang exp/system1/tri3b exp/system1/tri3b_ali

echo -e "SAT+FMLLR training done.\n"
