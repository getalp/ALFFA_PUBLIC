#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM

# SGMM ---> 19.52 

steps/train_ubm.sh  500 data/train lang exp/system1/tri3b_ali exp/system1/ubm5b2 || exit 1;
steps/train_sgmm2.sh  5000 12000 data/train lang exp/system1/tri3b_ali exp/system1/ubm5b2/final.ubm exp/system1/sgmm2_5b2 || exit 1;
utils/mkgraph.sh lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2/graph
steps/decode_sgmm2.sh --nj 4  --transform-dir exp/system1/tri3b/decode_test exp/system1/sgmm2_5b2/graph data/test exp/system1/sgmm2_5b2/decode_test
steps/align_sgmm2.sh --nj 20  --transform-dir exp/system1/tri3b_ali  --use-graphs true --use-gselect true data/train lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2_ali  || exit 1; 
steps/make_denlats_sgmm2.sh --nj 20 --sub-split 20  --transform-dir exp/system1/tri3b_ali data/train lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats  || exit 1;
steps/train_mmi_sgmm2.sh  --transform-dir exp/system1/tri3b_ali --boost 0.1 data/train lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1  || exit 1;

for iter in 1 2 3 4; do
	steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1/tri3b/decode_test lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it$iter 
done

steps/train_mmi_sgmm2.sh  --transform-dir exp/tri3b_ali --boost 0.1 --zero-if-disjoint true data/train lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1_z

for iter in 1 2 3 4; do
	steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1/tri3b/decode_test lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1_z/decode_test_it$iter
done


# MBR ---> 19.49
cp -r -T exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3{,.mbr}
local/score_mbr.sh data/test lang exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3.mbr


# SGMM+MMI+fMMI ---> 18.00

#local/score_combine.sh data/test lang exp/system1/tri3b_fmmi_indirect/decode_test_it3  exp/system1/sgmm2_5b_mmi_b0.1/decode_test_it3 exp/system1/combine_tri3b_fmmi_indirect_sgmm2_5b_mmi_b0.1/decode_test_it8_3


