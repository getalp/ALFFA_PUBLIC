#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi/wolof
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

# SGMM
echo -e "SGMM step.\n"
$KALDI_DIR/steps/train_ubm.sh  600 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/ubm5b2 || exit 1;
$KALDI_DIR/steps/train_sgmm2.sh  11000 25000 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_ali exp/system1_NoLengthContrast/ubm5b2/final.ubm exp/system1_NoLengthContrast/sgmm2_5b2 || exit 1;
utils/mkgraph.sh lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2 exp/system1_NoLengthContrast/sgmm2_5b2/graph
$KALDI_DIR/steps/decode_sgmm2.sh --nj 2  --transform-dir exp/system1_NoLengthContrast/tri3b/decode_dev exp/system1_NoLengthContrast/sgmm2_5b2/graph data/dev exp/system1_NoLengthContrast/sgmm2_5b2/decode_dev
$KALDI_DIR/steps/decode_sgmm2.sh --nj 2  --transform-dir exp/system1_NoLengthContrast/tri3b/decode_test exp/system1_NoLengthContrast/sgmm2_5b2/graph data/test exp/system1_NoLengthContrast/sgmm2_5b2/decode_test
$KALDI_DIR/steps/align_sgmm2.sh --nj 14 --transform-dir exp/system1_NoLengthContrast/tri3b_ali  --use-graphs true --use-gselect true data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2 exp/system1_NoLengthContrast/sgmm2_5b2_ali  || exit 1; 
$KALDI_DIR/steps/make_denlats_sgmm2.sh --nj 14 --sub-split 14 --transform-dir exp/system1_NoLengthContrast/tri3b_ali data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2_ali exp/system1_NoLengthContrast/sgmm2_5b2_denlats  || exit 1;
echo -e "SGMM+MMI step.\n"
$KALDI_DIR/steps/train_mmi_sgmm2.sh  --transform-dir exp/system1_NoLengthContrast/tri3b_ali --boost 0.1 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2_ali exp/system1_NoLengthContrast/sgmm2_5b2_denlats exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1  || exit 1;

for iter in 1 2 3 4; do
$KALDI_DIR/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_dev lang_o3g_NoLengthContrast data/dev exp/system1_NoLengthContrast/sgmm2_5b2/decode_dev exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_dev_it$iter 
$KALDI_DIR/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_test lang_o3g_NoLengthContrast data/test exp/system1_NoLengthContrast/sgmm2_5b2/decode_test exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_test_it$iter 
done

$KALDI_DIR/steps/train_mmi_sgmm2.sh  --transform-dir exp/system1_NoLengthContrast/tri3b_ali --boost 0.1 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2_ali exp/system1_NoLengthContrast/sgmm2_5b2_denlats exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1_z

for iter in 1 2 3 4; do
$KALDI_DIR/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_dev lang_o3g_NoLengthContrast data/dev exp/system1_NoLengthContrast/sgmm2_5b2/decode_dev exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1_z/decode_dev_it$iter
$KALDI_DIR/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir exp/system1_NoLengthContrast/tri3b/decode_test lang_o3g_NoLengthContrast data/test exp/system1_NoLengthContrast/sgmm2_5b2/decode_test exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1_z/decode_test_it$iter
done

# MBR
echo -e "rescore mbr step.\n" 
cp -r -T exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_dev_it3{,.mbr}
cp -r -T exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_test_it3{,.mbr}
local/score_mbr.sh data/dev lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_dev_it3.mbr
local/score_mbr.sh data/test lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_test_it3.mbr

# SGMM+MMI+fMMI
echo -e "rescore sgmm+mmi+fmmi step.\n"
local/score_combine.sh data/dev lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_fmmi_indirect/decode_dev_it3 exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_dev_it3 exp/system1_NoLengthContrast/combine_tri3b_fmmi_indirect_sgmm2_5b2_mmi_b0.1/decode_dev_it8_3
local/score_combine.sh data/test lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b_fmmi_indirect/decode_test_it3 exp/system1_NoLengthContrast/sgmm2_5b2_mmi_b0.1/decode_test_it3 exp/system1_NoLengthContrast/combine_tri3b_fmmi_indirect_sgmm2_5b2_mmi_b0.1/decode_test_it8_3

#RESULTS
for x in exp/system1_NoLengthContrast/sgmm2_5b2*/decode_*combine_LM1-web*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS
