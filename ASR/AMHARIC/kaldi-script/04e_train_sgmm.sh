#!/bin/sh

. 00_init_paths.sh



###SGMM
#training steps
$KALDI_DIR/egs/wsj/s5/steps/train_ubm.sh  600 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/ubm5b2 || exit 1;
$KALDI_DIR/egs/wsj/s5/steps/train_sgmm2.sh  11000 25000 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_ali $TRAIN_EXP_DIR/ubm5b2/final.ubm $TRAIN_EXP_DIR/sgmm2_5b2 || exit 1;
utils/mkgraph.sh $WORK_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2 $TRAIN_EXP_DIR/sgmm2_5b2/graph
#decoding step
$KALDI_DIR/egs/wsj/s5/steps/decode_sgmm2.sh --nj 6  --transform-dir $TRAIN_EXP_DIR/tri3b/decode $TRAIN_EXP_DIR/sgmm2_5b2/graph $DATA_DIR/test $TRAIN_EXP_DIR/sgmm2_5b2/decode

#sgmm alignement
$KALDI_DIR/egs/wsj/s5/steps/align_sgmm2.sh --nj 20  --transform-dir $TRAIN_EXP_DIR/tri3b_ali  --use-graphs true --use-gselect true $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2 $TRAIN_EXP_DIR/sgmm2_5b2_ali  || exit 1; 
$KALDI_DIR/egs/wsj/s5/steps/make_denlats_sgmm2.sh --nj 20 --sub-split 20  --transform-dir $TRAIN_EXP_DIR/tri3b_ali $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2_ali $TRAIN_EXP_DIR/sgmm2_5b2_denlats  || exit 1;

###SGMM+MMI
#training step	
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_sgmm2.sh  --transform-dir $TRAIN_EXP_DIR/tri3b_ali --boost 0.1 $DATA_DIR/train $WORK_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2_ali $TRAIN_EXP_DIR/sgmm2_5b2_denlats $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1  || exit 1;
#decoding step
for iter in 1 2 3 4; do
	$KALDI_DIR/egs/wsj/s5/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir $TRAIN_EXP_DIR/tri3b/decode $WORK_DIR/lang $DATA_DIR/test $TRAIN_EXP_DIR/sgmm2_5b2/decode $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1/decode_it$iter 
done

#training step
$KALDI_DIR/egs/wsj/s5/steps/train_mmi_sgmm2.sh  --transform-dir $TRAIN_EXP_DIR/tri3b_ali --boost 0.1 --zero-if-disjoint true $DATA_DIR/train $WORD_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2_ali $TRAIN_EXP_DIR/sgmm2_5b2_denlats $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1_z
#decoding step
for iter in 1 2 3 4; do
	$KALDI_DIR/egs/wsj/s5/steps/decode_sgmm2_rescore.sh  --iter $iter --transform-dir $TRAIN_EXP_DIR/tri3b/decode $WORK_DIR/lang $DATA_DIR/test $TRAIN_EXP_DIR/sgmm2_5b2/decode $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1_z/decode_it$iter
done


#decoding step
cp -r -T $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1/decode_it3{,.mbr}
$KALDI_DIR/egs/wsj/s5/local/score_mbr.sh $DATA_DIR/test $WORK_DIR/lang $TRAIN_EXP_DIR/sgmm2_5b2_mmi_b0.1/decode_it3.mbr


# SGMM+MMI+fMMI ---> 18.00
#scoring
$KALDI_DIR/egs/wsj/s5/local/score_combine.sh $DATA_DIR/test $WORK_DIR/lang $TRAIN_EXP_DIR/tri3b_fmmi_indirect/decode_it3  $TRAIN_EXP_DIR/sgmm2_5b_mmi_b0.1/decode_it3 $TRAIN_EXP_DIR/combine_tri3b_fmmi_indirect_sgmm2_5b_mmi_b0.1/decode_it8_3


