#!/bin/sh

. 00_init_paths.sh


# decoding stage will present two results ; decode_si and decode in tri3b folder.
# decode_si gives results with SAT and decode gives results with SAT and fMLLR applied 



# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM
# SAT+FMLLR ---> 25.46

#training steps
$KALDI_DIR/egs/wsj/s5/steps/align_si.sh  --nj 20 --use-graphs true $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri2b $TRAIN_EXP_DIR/tri2b_ali
$KALDI_DIR/egs/wsj/s5/steps/train_sat.sh 4200 40000 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri2b_ali $TRAIN_EXP_DIR/tri3b
$KALDI_DIR/egs/wsj/s5/utils/mkgraph.sh $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b $TRAIN_EXP_DIR/tri3b/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode_fmllr.sh --nj 6  $TRAIN_EXP_DIR/tri3b/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri3b/decode

#training step for fmllr alignement
$KALDI_DIR/egs/wsj/s5/steps/align_fmllr.sh --nj 20 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b $TRAIN_EXP_DIR/tri3b_ali

