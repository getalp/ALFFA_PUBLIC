#!/bin/sh

# Copyright 2012-2014  Brno University of Technology (Author: Karel Vesely)
# Apache 2.0

# This example script trains a DNN on top of fMLLR features. 
# The training is done in 3 stages,
#
# 1) RBM pre-training:
#    in this unsupervised stage we train stack of RBMs, 
#    a good starting point for frame cross-entropy trainig.
# 2) frame cross-entropy training:
#    the objective is to classify frames to correct pdfs.
# 3) sequence-training optimizing sMBR: 
#    the objective is to emphasize state-sequences with better 
#    frame accuracy w.r.t. reference alignment.


. ./path.sh ## Source the tools/utils (import the queue.pl)

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi-trunk
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

# Config:
gmmdir=exp/system1_NoLengthContrast/tri3b
data_fmllr=data-fmllr/system1_NoLengthContrast
stage=0 # resume training with --stage=N
# End of config.
. $KALDI_DIR/egs/wsj/s5/utils/parse_options.sh || exit 1;
#

if [ $stage -le 0 ]; then
  # Store fMLLR features, so we can train on them easily,
  # dev
  dir=$data_fmllr/dev
  $KALDI_DIR/egs/wsj/s5/steps/nnet/make_fmllr_feats.sh --nj 2 --cmd "$train_cmd" \
     --transform-dir $gmmdir/decode_dev \
     $dir data/dev $gmmdir $dir/log $dir/data || exit 1
  # test
  dir=$data_fmllr/test
  $KALDI_DIR/egs/wsj/s5/steps/nnet/make_fmllr_feats.sh --nj 2 --cmd "$train_cmd" \
     --transform-dir $gmmdir/decode_test \
     $dir data/test $gmmdir $dir/log $dir/data || exit 1
  # train
  dir=$data_fmllr/train
  $KALDI_DIR/egs/wsj/s5/steps/nnet/make_fmllr_feats.sh --nj 14 --cmd "$train_cmd" \
     --transform-dir ${gmmdir}_ali \
     $dir data/train $gmmdir $dir/log $dir/data || exit 1
  # split the data : 90% train 10% cross-validation (held-out)
  utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10 || exit 1
fi

if [ $stage -le 1 ]; then
  # Pre-train DBN, i.e. a stack of RBMs (small database, smaller DNN)
  dir=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn
  (tail --pid=$$ -F $dir/log/pretrain_dbn.log 2>/dev/null)& # forward log
  $cuda_cmd $dir/log/pretrain_dbn.log \
     $KALDI_DIR/egs/wsj/s5/steps/nnet/pretrain_dbn.sh --hid-dim 1024 --rbm-iter 14 $data_fmllr/train $dir || exit 1;
fi

if [ $stage -le 2 ]; then
  # Train the DNN optimizing per-frame cross-entropy.
  dir=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn_dnn
  ali=${gmmdir}_ali
  feature_transform=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn/final.feature_transform
  dbn=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn/6.dbn
  (tail --pid=$$ -F $dir/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir/log/train_nnet.log \
  $dir/log/train_nnet.log \ 
    $KALDI_DIR/egs/wsj/s5/steps/nnet/train.sh --feature-transform $feature_transform --dbn $dbn --hid-layers 0 --learn-rate 0.008 \
    $data_fmllr/${TRAIN_DIR}_tr90 $data_fmllr/${TRAIN_DIR}_cv10 lang_o3g_NoLengthContrast $ali $ali $dir || exit 1;
  # Decode (reuse HCLG graph)
  $KALDI_DIR/egs/wsj/s5/steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config $KALDI_DIR/egs/wsj/s5/conf/decode_dnn.config --acwt 0.1 \
    $gmmdir/graph $data_fmllr/dev $dir/decode_dev || exit 1;
  $KALDI_DIR/egs/wsj/s5/steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config $KALDI_DIR/egs/wsj/s5/conf/decode_dnn.config --acwt 0.1 \
    $gmmdir/graph $data_fmllr/test $dir/decode_test || exit 1;
  #steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
  #  $gmmdir/graph_ug $data_fmllr/test $dir/decode_ug || exit 1;
fi


# Sequence training using sMBR criterion, we do Stochastic-GD 
# with per-utterance updates. We use usually good acwt 0.1
dir=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn_dnn_smbr
srcdir=exp/system1_NoLengthContrast/dnn4b_pretrain-dbn_dnn
acwt=0.1

if [ $stage -le 3 ]; then
  # First we generate lattices and alignments:
  $KALDI_DIR/egs/wsj/s5/steps/nnet/align.sh --nj 14 --cmd "$train_cmd" \
    $data_fmllr/train lang_o3g_NoLengthContrast $srcdir ${srcdir}_ali || exit 1;
  $KALDI_DIR/egs/wsj/s5/steps/nnet/make_denlats.sh --nj 14 --cmd "$decode_cmd" --config $KALDI_DIR/egs/wsj/s5/conf/decode_dnn.config --acwt $acwt \
    $data_fmllr/train lang_o3g_NoLengthContrast $srcdir ${srcdir}_denlats || exit 1;
fi

if [ $stage -le 4 ]; then
  # Re-train the DNN by 2 iterations of sMBR 
  $KALDI_DIR/egs/wsj/s5/steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters 6 --acwt $acwt --do-smbr true \
    $data_fmllr/train lang_o3g_NoLengthContrast $srcdir ${srcdir}_ali ${srcdir}_denlats $dir || exit 1
  # Decode
  for ITER in 1 2 3 4 5 6; do
    $KALDI_DIR/egs/wsj/s5/steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config $KALDI_DIR/egs/wsj/s5/conf/decode_dnn.config \
      --nnet $dir/${ITER}.nnet --acwt $acwt \
      $gmmdir/graph $data_fmllr/dev $dir/decode_dev_it${ITER} || exit 1;
    $KALDI_DIR/egs/wsj/s5/steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config $KALDI_DIR/egs/wsj/s5/conf/decode_dnn.config \
      --nnet $dir/${ITER}.nnet --acwt $acwt \
      $gmmdir/graph $data_fmllr/test $dir/decode_test_it${ITER} || exit 1;
    #steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config \
    #  --nnet $dir/${ITER}.nnet --acwt $acwt \
    #  $gmmdir/graph_ug $data_fmllr/test $dir/decode_ug_it${ITER} || exit 1
  done 
fi

# Getting results [see RESULTS file]
for x in exp/system1_NoLengthContrast/dnn*/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done >> exp/system1_NoLengthContrast/RESULTS

echo Success
exit 0

# Showing how model conversion to nnet2 works; note, we use the expanded variable
# names here so be careful in case the script changes.
 #steps/nnet2/convert_nnet1_to_nnet2.sh exp/system1/dnn4b_pretrain-dbn_dnn exp/system1/dnn4b_nnet2
 #cp exp/system1/tri3b/splice_opts exp/system1/tri3b/cmvn_opts exp/system1/tri3b/final.mat exp/system1/dnn4b_nnet2/
# 
  #steps/nnet2/decode.sh --nj 10 --cmd "$decode_cmd" --transform-dir exp/system1/tri3b/decode \
  #steps/nnet2/decode.sh --nj 10 --transform-dir exp/system1/tri3b/decode \ 
  #  --config conf/decode.config exp/system1/tri3b/graph data/dev exp/system1/dnn4b_nnet2/decode

# decoding results are essentially the same (any small difference is probably because
# decode.config != decode_dnn.config).
# %WER 1.58 [ 198 / 12533, 22 ins, 45 del, 131 sub ] exp/system1/dnn4b_nnet2/decode/wer_3
# %WER 1.59 [ 199 / 12533, 23 ins, 45 del, 131 sub ] exp/system1/dnn4b_pretrain-dbn_dnn/decode/wer_3
