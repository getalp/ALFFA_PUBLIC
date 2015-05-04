#!/bin/sh

. 00_init_paths.sh

# TODO : 
#       - AM : quinphones, MLP ....
#       - LM : perplexity on dev, native 4g, rnnLM


## triphones
#training steps
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh --boost-silence 1.25 --nj 20  $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/mono $TRAIN_EXP_DIR/mono_ali
$KALDI_DIR/egs/wsj/s5/steps/train_deltas.sh --boost-silence 1.25  4200 40000 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/mono_ali $TRAIN_EXP_DIR/tri1
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh $WORK_DIR/lang $TRAIN_EXP_DIR/tri1 $TRAIN_EXP_DIR/tri1/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 6  $TRAIN_EXP_DIR/tri1/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri1/decode

## triphones + delta delta
#training steps
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh  --nj 20  $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri1 $TRAIN_EXP_DIR/tri1_ali
$KALDI_DIR/egs/wsj/s5/steps/train_deltas.sh  4200 40000  $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri1_ali $TRAIN_EXP_DIR/tri2a
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh $WORK_DIR/lang  $TRAIN_EXP_DIR/tri2a $TRAIN_EXP_DIR/tri2a/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 6  $TRAIN_EXP_DIR/tri2a/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri2a/decode
