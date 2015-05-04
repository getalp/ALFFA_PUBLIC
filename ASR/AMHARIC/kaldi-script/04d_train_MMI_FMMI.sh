#!/bin/sh

. 00_init_paths.sh

# TODO : 
#	- AM : quinphones, MLP ....
#	- LM : perplexity on dev, native 4g, rnnLM

# MMI ---> 22.15

#training steps
$KALDI_DIR/egs/wsj/s5/steps/make_denlats.sh --nj 20 --sub-split 20 --transform-dir $TRAIN_EXP_DIR/tri3b_ali $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b $TRAIN_EXP_DIR/tri3b_denlats || exit 1;
$KALDI_DIR/egs/wsj/s5/steps/train_mmi.sh --boost 0.1 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/tri3b_denlats $TRAIN_EXP_DIR/tri3b_mmi_b0.1  || exit 1;
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode.sh --nj 6 --transform-dir $TRAIN_EXP_DIR/tri3b/decode $TRAIN_EXP_DIR/tri3b/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri3b_mmi_b0.1/decode

#first, train UBM for fMMI experiments.
$KALDI_DIR/egs/wsj/s5/steps/train_diag_ubm.sh --silence-weight 0.5 --nj 20 600 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/dubm3b

# fMMI+MMI ---> 21.15
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_fmmi.sh --boost 0.1 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/dubm3b $TRAIN_EXP_DIR/tri3b_denlats $TRAIN_EXP_DIR/tri3b_fmmi_a || exit 1;

for iter in 3 4 5 6 7 8;
 do
	$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 6  --iter $iter --transform-dir $TRAIN_EXP_DIR/tri3b/decode $TRAIN_EXP_DIR/tri3b/graph $DATA_DIR/dev $TRAIN_EXP_DIR/tri3b_fmmi_a/decode_it$iter
done

# fMMI + mmi with indirect differential ---> 20.65
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_fmmi_indirect.sh --boost 0.1 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/dubm3b $TRAIN_EXP_DIR/tri3b_denlats $TRAIN_EXP_DIR/tri3b_fmmi_indirect || exit 1;

for iter in 3 4 5 6 7 8;
 do
	$KALDI_DIR/egs/wsj/s5/steps/decode_fmmi.sh --nj 6  --iter $iter --transform-dir  $TRAIN_EXP_DIR/tri3b/decode $TRAIN_EXP_DIR/tri3b/graph $DATA_DIR/test $TRAIN_EXP_DIR/tri3b_fmmi_indirect/decode_it$iter
done

