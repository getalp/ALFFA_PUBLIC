#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi-trunk
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

## triphones
echo -e "triphones step \n"
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh --boost-silence 1.25 --nj 14  data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/mono exp/system1_NoLengthContrast/mono_ali
$KALDI_DIR/egs/wsj/s5/steps/train_deltas.sh --boost-silence 1.25  4200 40000 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/mono_ali exp/system1_NoLengthContrast/tri1
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri1 exp/system1_NoLengthContrast/tri1/graph
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri1/graph data/dev exp/system1_NoLengthContrast/tri1/decode_dev
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri1/graph data/test exp/system1_NoLengthContrast/tri1/decode_test

## triphones + delta delta
echo -e "\ntriphones + delta delta step \n"
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh  --nj 14  data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri1 exp/system1_NoLengthContrast/tri1_ali
$KALDI_DIR/egs/wsj/s5/steps/train_deltas.sh  4200 40000  data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri1_ali exp/system1_NoLengthContrast/tri2a
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh lang_o3g_NoLengthContrast  exp/system1_NoLengthContrast/tri2a exp/system1_NoLengthContrast/tri2a/graph
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri2a/graph data/dev exp/system1_NoLengthContrast/tri2a/decode_dev
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri2a/graph data/test exp/system1_NoLengthContrast/tri2a/decode_test
  
#results
for x in exp/system1_NoLengthContrast/tri*/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS
