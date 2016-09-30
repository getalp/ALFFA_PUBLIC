#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi-trunk
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

# LDA+MLLT
echo -e "\nLDA+MLLT step.\n"
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh  --nj 14  data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri2a exp/system1_NoLengthContrast/tri2a_ali
$KALDI_DIR/egs/wsj/s5/steps/train_lda_mllt.sh   --splice-opts "--left-context=3 --right-context=3"   4200 40000 data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/tri2a_ali exp/system1_NoLengthContrast/tri2b
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh lang_o3g_NoLengthContrast  exp/system1_NoLengthContrast/tri2b exp/system1_NoLengthContrast/tri2b/graph
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri2b/graph $DATA_DIR/dev exp/system1_NoLengthContrast/tri2b/decode_dev
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/tri2b/graph $DATA_DIR/test exp/system1_NoLengthContrast/tri2b/decode_test

##results
for x in exp/system1_NoLengthContrast/tri2b/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS
