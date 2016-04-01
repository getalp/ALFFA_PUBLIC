#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi/wolof
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

# monophones
echo -e "monophones step \n"
  $KALDI_DIR/steps/train_mono.sh  --nj 14  data/train lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/mono 
  $KALDI_DIR/utils/mkgraph.sh --mono lang_o3g_NoLengthContrast exp/system1_NoLengthContrast/mono exp/system1_NoLengthContrast/mono/graph
  $KALDI_DIR/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/mono/graph data/dev exp/system1_NoLengthContrast/mono/decode_dev
  $KALDI_DIR/steps/decode.sh --nj 2  exp/system1_NoLengthContrast/mono/graph data/test exp/system1_NoLengthContrast/mono/decode_test
  
  #results
  for x in exp/system1_NoLengthContrast/mono/decode_*; do [ -d $x ] && grep WER $x/wer_* | $KALDI_DIR/utils/best_wer.sh; done > exp/system1_NoLengthContrast/RESULTS
#popd
