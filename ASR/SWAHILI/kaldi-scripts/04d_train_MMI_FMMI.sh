#!/bin/sh

#. ./path.sh
. ./00_init_paths.sh  || die "00_init_paths.sh expected";


# MMI

steps/make_denlats.sh --nj 4 --sub-split 4 --transform-dir exp/system1/tri3b_ali data/train data/lang exp/system1/tri3b exp/system1/tri3b_denlats || exit 1;
steps/train_mmi.sh --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/tri3b_denlats exp/system1/tri3b_mmi_b0.1  || exit 1;

steps/decode.sh --nj 4 --transform-dir exp/system1/tri3b/decode_test exp/system1/tri3b/graph data/test exp/system1/tri3b_mmi_b0.1/decode_test

# first, train UBM for fMMI experiments.
steps/train_diag_ubm.sh --silence-weight 0.5 --nj 4 600 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b

# fMMI+MMI ---> 21.15
steps/train_mmi_fmmi.sh --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_a || exit 1;

for iter in 3 4 5 6 7 8; do
	steps/decode_fmmi.sh --nj 4  --iter $iter --transform-dir exp/system1/tri3b/decode_test  exp/system1/tri3b/graph data/test  exp/system1/tri3b_fmmi_a/decode_test_it$iter
done

# fMMI + mmi with indirect differential ---> 20.65
steps/train_mmi_fmmi_indirect.sh --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_indirect || exit 1;

for iter in 3 4 5 6 7 8; do
 steps/decode_fmmi.sh --nj 4  --iter $iter --transform-dir exp/system1/tri3b/decode_test  exp/system1/tri3b/graph data/test exp/system1/tri3b_fmmi_indirect/decode_test_it$iter
done

echo -e "fMMI+MMI training done.\n"
