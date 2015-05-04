#!/bin/sh

. 00_init_paths.sh

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM
# LDA+MLLT

#training steps
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh --nj 20 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri2a $TRAIN_EXP_DIR/tri2a_ali
$KALDI_DIR/egs/wsj/s5/steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3"   4200 40000 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri2a_ali $TRAIN_EXP_DIR/tri2b
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh $WORK_DIR/lang  $TRAIN_EXP_DIR/tri2b $TRAIN_EXP_DIR/tri2b/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 6  $TRAIN_EXP_DIR/tri2b/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri2b/decode

