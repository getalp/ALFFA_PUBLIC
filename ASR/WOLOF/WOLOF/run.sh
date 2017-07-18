#!/bin/bash

# initialization PATH
. ./kaldi-scripts/00_init_paths.sh || { echo -e "\n00_init_paths.sh expected.\n"; exit; }


##### DATA PREPARATION #####
# Create symbolic links used by Kaldi
./kaldi-scripts/01_init_symlink.sh
# Create and prepare dict/ directory
./kaldi-scripts/02_lexicon.sh
# Create and prepare lang/ directory
utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
# Prepare grammar from language model
./kaldi-scripts/03_lm_preparation.sh
# Prepare data
./kaldi-scripts/04_data_prep.sh
# Compute MFCC
echo "compute mfcc for train dev test..."
for dir in "train" "dev" "test"
do
  steps/make_mfcc.sh --nj 4 data/$dir data/exp/make_mfcc/$dir data/$dir/mfcc
  steps/compute_cmvn_stats.sh data/$dir data/exp/make_mfcc/$dir data/$dir/mfcc
done
echo -e "compute mfcc done.\n"


##### ASR BUILDING #####
# initialization commands
. ./cmd.sh || { echo -e "\n cmd.sh expected.\n"; exit; }

# monophones
echo
echo "===== MONO TRAINING ====="
echo
# Training
steps/train_mono.sh --nj 14 --cmd utils/run.pl data/train data/lang exp/system1/mono
echo
echo "===== MONO DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh --mono data/lang exp/system1/mono exp/system1/mono/graph
# Decoding
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/mono/graph data/dev exp/system1/mono/decode_dev
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/mono/graph data/test exp/system1/mono/decode_test
echo
echo "===== MONO ALIGNMENT ====="
echo
steps/align_si.sh --boost-silence 1.25 --nj 14 --cmd utils/run.pl data/train data/lang exp/system1/mono exp/system1/mono_ali

## Triphone
echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo
# Training
echo -e "triphones step \n"
steps/train_deltas.sh --boost-silence 1.25 --cmd utils/run.pl 4200 40000 data/train data/lang exp/system1/mono_ali exp/system1/tri1
echo
echo "===== TRI1 (first triphone pass) DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/tri1 exp/system1/tri1/graph
# Decoding
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri1/graph data/dev exp/system1/tri1/decode_dev
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri1/graph data/test exp/system1/tri1/decode_test
echo
echo "===== TRI1 (first triphone pass) ALIGNMENT ====="
echo
steps/align_si.sh --nj 14 --cmd utils/run.pl data/train data/lang exp/system1/tri1 exp/system1/tri1_ali

## Triphone + Delta Delta
echo
echo "===== TRI2a (second triphone pass) TRAINING ====="
echo
# Training
steps/train_deltas.sh --cmd utils/run.pl 4200 40000  data/train data/lang exp/system1/tri1_ali exp/system1/tri2a
echo
echo "===== TRI2a (second triphone pass) DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/tri2a exp/system1/tri2a/graph
# Decoding
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri2a/graph data/dev exp/system1/tri2a/decode_dev
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri2a/graph data/test exp/system1/tri2a/decode_test
echo
echo "===== TRI2a (second triphone pass) ALIGNMENT ====="
echo
steps/align_si.sh --nj 14 --cmd utils/run.pl data/train data/lang exp/system1/tri2a exp/system1/tri2a_ali

## Triphone + Delta Delta + LDA and MLLT
echo
echo "===== TRI2b (third triphone pass) TRAINING ====="
echo
# Training
steps/train_lda_mllt.sh --cmd utils/run.pl --splice-opts "--left-context=3 --right-context=3"   4200 40000 data/train data/lang exp/system1/tri2a_ali exp/system1/tri2b
echo
echo "===== TRI2b (third triphone pass) DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/tri2b exp/system1/tri2b/graph
# Decoding
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri2b/graph $DATA_DIR/dev exp/system1/tri2b/decode_dev
steps/decode.sh --nj 2 --cmd utils/run.pl exp/system1/tri2b/graph $DATA_DIR/test exp/system1/tri2b/decode_test
echo
echo "===== TRI2b (third triphone pass) ALIGNMENT ====="
echo
steps/align_si.sh --nj 14 --cmd utils/run.pl --use-graphs true data/train data/lang exp/system1/tri2b exp/system1/tri2b_ali

## Triphone + Delta Delta + LDA and MLLT + SAT and FMLLR
echo
echo "===== TRI3b (fourth triphone pass) TRAINING ====="
echo
# Training
steps/train_sat.sh --cmd utils/run.pl 4200 40000 data/train data/lang exp/system1/tri2b_ali exp/system1/tri3b
echo
echo "===== TRI3b (fourth triphone pass) DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/tri3b exp/system1/tri3b/graph
# Decoding
steps/decode_fmllr.sh --nj 2 --cmd utils/run.pl exp/system1/tri3b/graph $DATA_DIR/dev exp/system1/tri3b/decode_dev
steps/decode_fmllr.sh --nj 2 --cmd utils/run.pl exp/system1/tri3b/graph $DATA_DIR/test exp/system1/tri3b/decode_test
echo
echo "===== TRI3b (fourth triphone pass) ALIGNMENT ====="
echo
# HMM/GMM aligments
steps/align_fmllr.sh --nj 14 --cmd utils/run.pl data/train data/lang exp/system1/tri3b exp/system1/tri3b_ali

echo
echo "===== CREATE DENOMINATOR LATTICES FOR MMI TRAINING ====="
echo
steps/make_denlats.sh --nj 14 --cmd utils/run.pl --sub-split 14 --transform-dir exp/system1/tri3b_ali data/train data/lang exp/system1/tri3b exp/system1/tri3b_denlats || exit 1;

## Triphone + LDA and MLLT + SAT and FMLLR + fMMI and MMI
# Training
echo
echo "===== TRI3b_MMI (fifth triphone pass) TRAINING ====="
echo
steps/train_mmi.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/tri3b_denlats exp/system1/tri3b_mmi_b0.1  || exit 1;
# Decoding
echo
echo "===== TRI3b_MMI (fifth triphone pass) DECODING ====="
echo
steps/decode.sh --nj 2 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_dev exp/system1/tri3b/graph data/dev exp/system1/tri3b_mmi_b0.1/decode_dev
steps/decode.sh --nj 2 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_test exp/system1/tri3b/graph data/test exp/system1/tri3b_mmi_b0.1/decode_test

## UBM for fMMI experiments
# Training
echo
echo "===== DUBM3b (UBM for fMMI experiments) TRAINING ====="
echo
steps/train_diag_ubm.sh --silence-weight 0.5 --nj 14 --cmd utils/run.pl 600 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b

## fMMI+MMI
# Training
echo
echo "===== TRI3b_FMMI (fMMI+MMI) TRAINING ====="
echo
steps/train_mmi_fmmi.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_a || exit 1;
# Decoding
echo
echo "===== TRI3b_FMMI (fMMI+MMI) DECODING ====="
echo
for iter in 3 4 5 6 7 8; do
  steps/decode_fmmi.sh --nj 2 --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_dev exp/system1/tri3b/graph data/dev exp/system1/tri3b_fmmi_a/decode_dev_it$iter
  steps/decode_fmmi.sh --nj 2 --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test exp/system1/tri3b/graph data/test exp/system1/tri3b_fmmi_a/decode_test_it$iter
done

## fMMI + mmi with indirect differential
# Training
echo
echo "===== TRI3b_FMMI_INDIRECT (fMMI+MMI with indirect differential) TRAINING ====="
echo
steps/train_mmi_fmmi_indirect.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_indirect || exit 1;
# Decoding
echo
echo "===== TRI3b_FMMI_INDIRECT (fMMI+MMI with indirect differential) DECODING ====="
echo
for iter in 3 4 5 6 7 8; do
  steps/decode_fmmi.sh --nj 2 --cmd utils/run.pl --iter $iter --transform-dir  exp/system1/tri3b/decode_dev exp/system1/tri3b/graph data/dev exp/system1/tri3b_fmmi_indirect/decode_dev_it$iter
  steps/decode_fmmi.sh --nj 2 --cmd utils/run.pl --iter $iter --transform-dir  exp/system1/tri3b/decode_test exp/system1/tri3b/graph data/test exp/system1/tri3b_fmmi_indirect/decode_test_it$iter
done

### Triphone + LDA and MLLT + SGMM
echo
echo "===== UBM5b2 (UBM for SGMM experiments) TRAINING ====="
echo
steps/train_ubm.sh --cmd utils/run.pl 600 data/train data/lang exp/system1/tri3b_ali exp/system1/ubm5b2 || exit 1;
## SGMM
# Training
echo
echo "===== SGMM2_5b2 (subspace Gaussian mixture model) TRAINING ====="
echo
steps/train_sgmm2.sh --cmd utils/run.pl 11000 25000 data/train data/lang exp/system1/tri3b_ali exp/system1/ubm5b2/final.ubm exp/system1/sgmm2_5b2 || exit 1;
echo
echo "===== SGMM2_5b2 (subspace Gaussian mixture model) DECODING ====="
echo
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2/graph
# Decoding
steps/decode_sgmm2.sh --nj 2 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_dev exp/system1/sgmm2_5b2/graph data/dev exp/system1/sgmm2_5b2/decode_dev
steps/decode_sgmm2.sh --nj 2 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_test exp/system1/sgmm2_5b2/graph data/test exp/system1/sgmm2_5b2/decode_test
# SGMM alignments
echo
echo "===== SGMM2_5b2 (subspace Gaussian mixture model) ALIGNMENT ====="
echo
steps/align_sgmm2.sh --nj 14 --cmd utils/run.pl --transform-dir exp/system1/tri3b_ali  --use-graphs true --use-gselect true data/train data/lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2_ali  || exit 1; 

## Denlats
echo
echo "===== CREATE DENOMINATOR LATTICES FOR SGMM TRAINING ====="
echo
steps/make_denlats_sgmm2.sh --nj 14 --cmd utils/run.pl --sub-split 14 --transform-dir exp/system1/tri3b_ali data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats  || exit 1;

## SGMM+MMI
# Training
echo
echo "===== SGMM2_5b2_MMI (SGMM+MMI) TRAINING ====="
echo
steps/train_mmi_sgmm2.sh --cmd utils/run.pl --transform-dir exp/system1/tri3b_ali --boost 0.1 data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1  || exit 1;
# Decoding
echo
echo "===== SGMM2_5b2_MMI (SGMM+MMI) DECODING ====="
echo
for iter in 1 2 3 4; do
  steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_dev data/lang data/dev exp/system1/sgmm2_5b2/decode_dev exp/system1/sgmm2_5b2_mmi_b0.1/decode_dev_it$iter 
  steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test data/lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it$iter 
done

# Training
echo
echo "===== SGMM2_5b2_MMI_Z (SGMM+MMI) TRAINING ====="
echo
steps/train_mmi_sgmm2.sh --cmd utils/run.pl --transform-dir exp/system1/tri3b_ali --boost 0.1 data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1_z
# Decoding
echo
echo "===== SGMM2_5b2_MMI_Z (SGMM+MMI) DECODING ====="
echo
for iter in 1 2 3 4; do
  steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_dev data/lang data/dev exp/system1/sgmm2_5b2/decode_dev exp/system1/sgmm2_5b2_mmi_b0.1_z/decode_dev_it$iter
  steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test data/lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1_z/decode_test_it$iter
done

# MBR
echo
echo "===== MINIMUM BAYES RISK DECODING ====="
echo
cp -r -T exp/system1/sgmm2_5b2_mmi_b0.1/decode_dev_it3{,.mbr}
cp -r -T exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3{,.mbr}
local/score_mbr.sh data/dev data/lang exp/system1/sgmm2_5b2_mmi_b0.1/decode_dev_it3.mbr
local/score_mbr.sh data/test data/lang exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3.mbr

# SGMM+MMI+fMMI
echo
echo "===== SYSTEM COMBINATION USING MINIMUM BAYES RISK DECODING ====="
echo
local/score_combine.sh data/dev data/lang exp/system1/tri3b_fmmi_indirect/decode_dev_it3 exp/system1/sgmm2_5b2_mmi_b0.1/decode_dev_it3 exp/system1/combine_tri3b_fmmi_indirect_sgmm2_5b2_mmi_b0.1/decode_dev_it8_3
local/score_combine.sh data/test data/lang exp/system1/tri3b_fmmi_indirect/decode_test_it3 exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3 exp/system1/combine_tri3b_fmmi_indirect_sgmm2_5b2_mmi_b0.1/decode_test_it8_3

echo
echo "===== run.sh script is finished ====="
echo


# ## DNN
# echo
# echo "===== DNN DATA PREPARATION ====="
# echo
# # Config:
# gmmdir=exp/system1/tri3b
# data_fmllr=system1
# stage=0 # resume training with --stage=N
# # End of config.
# . utils/parse_options.sh || exit 1;
# #

# if [ $stage -le 0 ]; then
#   # Store fMLLR features, so we can train on them easily,
#   # dev
#   dir=$data_fmllr/dev
#   steps/nnet/make_fmllr_feats.sh --nj 2 --cmd "$train_cmd" \
#      --transform-dir $gmmdir/decode_dev \
#      $dir data/dev $gmmdir $dir/log $dir/data || exit 1
#   # test
#   dir=$data_fmllr/test
#   steps/nnet/make_fmllr_feats.sh --nj 2 --cmd "$train_cmd" \
#      --transform-dir $gmmdir/decode_test \
#      $dir data/test $gmmdir $dir/log $dir/data || exit 1
#   # train
#   dir=$data_fmllr/train
#   steps/nnet/make_fmllr_feats.sh --nj 14 --cmd "$train_cmd" \
#      --transform-dir ${gmmdir}_ali \
#      $dir data/train $gmmdir $dir/log $dir/data || exit 1
#   # split the data : 90% train 10% cross-validation (held-out)
#   utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10 || exit 1
# fi

# echo
# echo "===== DNN DATA TRAINING ====="
# echo
# # Training
# if [ $stage -le 1 ]; then
#   # Pre-train DBN, i.e. a stack of RBMs (small database, smaller DNN)
#   dir=exp/system1/dnn4b_pretrain-dbn
#   (tail --pid=$$ -F $dir/log/pretrain_dbn.log 2>/dev/null)& # forward log
#   $cuda_cmd $dir/log/pretrain_dbn.log \
#      steps/nnet/pretrain_dbn.sh --hid-dim 1024 --rbm-iter 14 $data_fmllr/train $dir || exit 1;
# fi

# if [ $stage -le 2 ]; then
#   # Train the DNN optimizing per-frame cross-entropy.
#   dir=exp/system1/dnn4b_pretrain-dbn_dnn
#   ali=${gmmdir}_ali
#   feature_transform=exp/system1/dnn4b_pretrain-dbn/final.feature_transform
#   dbn=exp/system1/dnn4b_pretrain-dbn/2.dbn
#   (tail --pid=$$ -F $dir/log/train_nnet.log 2>/dev/null)& # forward log
#   # Train
#   $cuda_cmd $dir/log/train_nnet.log \
#   $dir/log/train_nnet.log \ 
#     steps/nnet/train.sh --feature-transform $feature_transform --dbn $dbn --hid-layers 0 --learn-rate 0.008 \
#     $data_fmllr/${TRAIN_DIR}_tr90 $data_fmllr/${TRAIN_DIR}_cv10 lang $ali $ali $dir || exit 1;
#   # Decode (reuse HCLG graph)
#   steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
#     $gmmdir/graph $data_fmllr/dev $dir/decode_dev || exit 1;
#   steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
#     $gmmdir/graph $data_fmllr/test $dir/decode_test || exit 1;
# fi

# # Sequence training using sMBR criterion, we do Stochastic-GD 
# # with per-utterance updates. We use usually good acwt 0.1
# dir=exp/system1/dnn4b_pretrain-dbn_dnn_smbr
# srcdir=exp/system1/dnn4b_pretrain-dbn_dnn
# acwt=0.1

# if [ $stage -le 3 ]; then
#   # First we generate lattices and alignments:
#   steps/nnet/align.sh --nj 14 --cmd "$train_cmd" \
#     $data_fmllr/train lang $srcdir ${srcdir}_ali || exit 1;
#   steps/nnet/make_denlats.sh --nj 14 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt $acwt \
#     $data_fmllr/train lang $srcdir ${srcdir}_denlats || exit 1;
# fi

# if [ $stage -le 4 ]; then
#   # Re-train the DNN by 2 iterations of sMBR 
#   steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters 6 --acwt $acwt --do-smbr true \
#     $data_fmllr/train lang $srcdir ${srcdir}_ali ${srcdir}_denlats $dir || exit 1
#   # Decode
#   for ITER in 1 2 3 4 5 6; do
#     steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config \
#       --nnet $dir/${ITER}.nnet --acwt $acwt \
#       $gmmdir/graph $data_fmllr/dev $dir/decode_dev_it${ITER} || exit 1;
#     steps/nnet/decode.sh --nj 2 --cmd "$decode_cmd" --config conf/decode_dnn.config \
#       --nnet $dir/${ITER}.nnet --acwt $acwt \
#       $gmmdir/graph $data_fmllr/test $dir/decode_test_it${ITER} || exit 1;
#   done 
# fi

# echo Success
# exit 0


# Getting results [see RESULTS file]
for x in exp/system1/*/decode_*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done > exp/system1/RESULTS

echo
echo "===== See results in 'exp/system1/RESULTS' ====="
echo