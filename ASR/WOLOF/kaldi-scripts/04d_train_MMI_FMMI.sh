#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi-trunk
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

# MMI 
echo -e "MMI step.\n"
$KALDI_DIR/egs/wsj/s5/steps/make_denlats.sh --nj 14 --sub-split 14 --transform-dir exp/system1_NoLengthContrast/tri3b_ali data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b exp/system1_NoLengthContrast/tri3b_denlats || exit 1;
$KALDI_DIR/egs/wsj/s5/steps/train_mmi.sh --boost 0.1 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/tri3b_denlats exp/system1_NoLengthContrast/tri3b_mmi_b0.1  || exit 1;

$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2 --transform-dir exp/system1_NoLengthContrast/tri3b/decode_dev exp/system1_NoLengthContrast/tri3b/graph data/dev exp/system1_NoLengthContrast/tri3b_mmi_b0.1/decode_dev
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2 --transform-dir exp/system1_NoLengthContrast/tri3b/decode_test exp/system1_NoLengthContrast/tri3b/graph data/test exp/system1_NoLengthContrast/tri3b_mmi_b0.1/decode_test

#first, train UBM for fMMI exp/system1_NoLengthContrasteriments.
echo -e "UBM training for fMMI step.\n"
$KALDI_DIR/egs/wsj/s5/steps/train_diag_ubm.sh --silence-weight 0.5 --nj 14 600 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/dubm3b

# fMMI+MMI
echo -e "fMMI+MMI step.\n"
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_fmmi.sh --boost 0.1 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/dubm3b exp/system1_NoLengthContrast/tri3b_denlats exp/system1_NoLengthContrast/tri3b_fmmi_a || exit 1;

for iter in 3 4 5 6 7 8; do
$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 2  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_dev exp/system1_NoLengthContrast/tri3b/graph data/dev exp/system1_NoLengthContrast/tri3b_fmmi_a/decode_dev_it$iter
$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 2  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_test exp/system1_NoLengthContrast/tri3b/graph data/test exp/system1_NoLengthContrast/tri3b_fmmi_a/decode_test_it$iter
done

# fMMI + MMI  with indirect differential
echo -e "fMMI+MMI with indirect differential step.\n"
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_fmmi_indirect.sh --boost 0.1 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/dubm3b exp/system1_NoLengthContrast/tri3b_denlats exp/system1_NoLengthContrast/tri3b_fmmi_indirect || exit 1;

for iter in 3 4 5 6 7 8; do
$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 2  --iter $iter --transform-dir  exp/system1_NoLengthContrast/tri3b/decode_dev exp/system1_NoLengthContrast/tri3b/graph data/dev exp/system1_NoLengthContrast/tri3b_fmmi_indirect/decode_dev_it$iter
$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 2  --iter $iter --transform-dir  exp/system1_NoLengthContrast/tri3b/decode_test exp/system1_NoLengthContrast/tri3b/graph data/test exp/system1_NoLengthContrast/tri3b_fmmi_indirect/decode_test_it$iter
done

##RESULTS
for x in exp/system1_NoLengthContrast/tri3b_mmi*/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS
