#!/bin/sh

. 00_init_paths.sh

# TODO : 
#   - AM : quinphones, MLP ....
#   - LM : perplexity on dev, native 4g, rnnLM

# mono_phones ---> 57.82


#training steps
$KALDI_DIR/egs/wsj/s5/steps/train_mono.sh  --nj 20 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/mono 
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh --mono $WORK_DIR/lang $TRAIN_EXP_DIR/mono $TRAIN_EXP_DIR/mono/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 6  $TRAIN_EXP_DIR/mono/graph $DATA_DIR/test $TRAIN_EXP_DIR/mono/decode
