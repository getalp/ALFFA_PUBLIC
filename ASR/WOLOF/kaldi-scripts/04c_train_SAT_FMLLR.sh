#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi-trunk
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

# decoding stage will present two results ; decode_si and decode in tri3b folder.
# decode_si gives results with SAT and decode gives results with SAT and fMLLR applied 
echo -e "SAT+fMLLR step\n."
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh  --nj 14 --use-graphs true data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri2b exp/system1_NoLengthContrast/tri2b_ali
$KALDI_DIR/egs/wsj/s5/steps/train_sat.sh 4200 40000 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri2b_ali exp/system1_NoLengthContrast/tri3b
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b exp/system1_NoLengthContrast/tri3b/graph
$KALDI_DIR/egs/wsj/s5/steps/decode_fmllr.sh --nj 2  exp/system1_NoLengthContrast/tri3b/graph $DATA_DIR/dev exp/system1_NoLengthContrast/tri3b/decode_dev
$KALDI_DIR/egs/wsj/s5/steps/decode_fmllr.sh --nj 2  exp/system1_NoLengthContrast/tri3b/graph $DATA_DIR/test exp/system1_NoLengthContrast/tri3b/decode_test

steps/align_fmllr.sh --nj 14 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri3b exp/system1_NoLengthContrast/tri3b_ali

#results
for x in exp/system1_NoLengthContrast/tri3b/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS
