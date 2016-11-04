#!/bin/bash

# initialization PATH
. ./kaldi-scripts/00_init_paths.sh || die "00_init_paths.sh expected";


##### DATA PREPARATION #####
#Create symbolic links used by Kaldi
./kaldi-scripts/01_init_symlink.sh
#Create and prepare dict/ directory
./kaldi-scripts/02_lexicon.sh
#Create and prepare lang/ directory
utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
./kaldi-scripts/03_lm_preparation.sh
#Compute MFCC
steps/make_mfcc.sh --nj 4  data/train data/exp/make_mfcc/train data/train/mfcc
steps/make_mfcc.sh --nj 4  data/test data/exp/make_mfcc/test data/test/mfcc

steps/compute_cmvn_stats.sh data/train data/exp/make_mfcc/train data/train/mfcc/
steps/compute_cmvn_stats.sh data/test data/exp/make_mfcc/test data/test/mfcc/


##### ASR BUILDING #####
# initialization commands
. ./cmd.sh || die "cmd.sh expected";

### Mono
# Training
steps/train_mono.sh --nj 20 --cmd utils/run.pl data/train data/lang exp/system1/mono
# Graph compilation  
utils/mkgraph.sh --mono data/lang exp/system1/mono exp/system1/mono/graph

# Decoding
steps/decode.sh --nj 4 --cmd utils/run.pl exp/system1/mono/graph  data/test exp/system1/mono/decode_test
echo -e "Mono training done.\n"


### Triphone 
# Training
steps/align_si.sh --boost-silence 1.25 --nj 20 --cmd utils/run.pl data/train data/lang exp/system1/mono exp/system1/mono_ali
steps/train_deltas.sh --boost-silence 1.25 --cmd utils/run.pl 3200 30000 data/train data/lang exp/system1/mono_ali exp/system1/tri1
# Graph compilation
utils/mkgraph.sh data/lang  exp/system1/tri1 exp/system1/tri1/graph
# Decoding
steps/decode.sh --nj 4 --cmd utils/run.pl exp/system1/tri1/graph  data/test exp/system1/tri1/decode_test

## Triphones + delta delta
# Training
steps/align_si.sh --nj 20 --cmd utils/run.pl data/train data/lang exp/system1/tri1 exp/system1/tri1_ali
steps/train_deltas.sh --cmd utils/run.pl 3200 30000 data/train data/lang exp/system1/tri1_ali exp/system1/tri2a
# Graph compilation
utils/mkgraph.sh data/lang  exp/system1/tri2a exp/system1/tri2a/graph
# Decoding
steps/decode.sh --nj 4 --cmd utils/run.pl exp/system1/tri2a/graph  data/test exp/system1/tri2a/decode_test
echo -e "Triphone training done.\n"
### Triphone + LDA and MLLT
# Training
steps/align_si.sh --nj 20 --cmd utils/run.pl data/train data/lang exp/system1/tri2a exp/system1/tri2a_ali
steps/train_lda_mllt.sh --cmd utils/run.pl  --splice-opts "--left-context=3 --right-context=3"   2000 20000 data/train data/lang  exp/system1/tri2a_ali exp/system1/tri2b
# Graph compilation
utils/mkgraph.sh data/lang  exp/system1/tri2b exp/system1/tri2b/graph
# Decoding
steps/decode.sh --nj 4 --cmd utils/run.pl exp/system1/tri2b/graph  data/test exp/system1/tri2b/decode_test
echo -e "LDA+MLLT training done.\n"


### Triphone + LDA and MLLT + SAT and FMLLR
# Training
steps/align_si.sh --nj 20 --cmd utils/run.pl --use-graphs true data/train data/lang exp/system1/tri2b exp/system1/tri2b_ali
steps/train_sat.sh --cmd utils/run.pl 2000 20000 data/train data/lang exp/system1/tri2b_ali exp/system1/tri3b
# Graph compilation
utils/mkgraph.sh data/lang  exp/system1/tri3b exp/system1/tri3b/graph
# Decoding
steps/decode_fmllr.sh --nj 4 --cmd utils/run.pl exp/system1/tri3b/graph  data/test exp/system1/tri3b/decode_test
# 
steps/align_fmllr.sh --nj 20 --cmd utils/run.pl data/train data/lang exp/system1/tri3b exp/system1/tri3b_ali
echo -e "SAT+FMLLR training done.\n"


### Triphone + LDA and MLLT + SAT and FMLLR + fMMI and MMI
# Training
steps/make_denlats.sh --nj 20 --cmd utils/run.pl --sub-split 10 --transform-dir exp/system1/tri3b_ali data/train data/lang exp/system1/tri3b exp/system1/tri3b_denlats || exit 1;
steps/train_mmi.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/tri3b_denlats exp/system1/tri3b_mmi_b0.1  || exit 1;
# Decoding
steps/decode.sh --nj 4 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_test exp/system1/tri3b/graph data/test exp/system1/tri3b_mmi_b0.1/decode_test

## UBM for fMMI experiments
# Training
steps/train_diag_ubm.sh --silence-weight 0.5 --nj 20 --cmd utils/run.pl 600 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b

## fMMI+MMI
# Training
steps/train_mmi_fmmi.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_a || exit 1;
# Decoding
for iter in 3 4 5 6 7 8; do
        steps/decode_fmmi.sh --nj 4 --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test  exp/system1/tri3b/graph data/test  exp/system1/tri3b_fmmi_a/decode_test_it$iter
done

## fMMI + mmi with indirect differential
# Training
steps/train_mmi_fmmi_indirect.sh --cmd utils/run.pl --boost 0.1 data/train data/lang exp/system1/tri3b_ali exp/system1/dubm3b exp/system1/tri3b_denlats exp/system1/tri3b_fmmi_indirect || exit 1;
# Decoding
for iter in 3 4 5 6 7 8; do
 steps/decode_fmmi.sh --nj 4 --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test  exp/system1/tri3b/graph data/test exp/system1/tri3b_fmmi_indirect/decode_test_it$iter
done
echo -e "fMMI+MMI training done.\n"


### Triphone + LDA and MLLT + SGMM
## SGMM
# Training
steps/train_ubm.sh --cmd utils/run.pl  500 data/train data/lang exp/system1/tri3b_ali exp/system1/ubm5b2 || exit 1;
steps/train_sgmm2.sh  --cmd utils/run.pl 5000 12000 data/train data/lang exp/system1/tri3b_ali exp/system1/ubm5b2/final.ubm exp/system1/sgmm2_5b2 || exit 1;
# Graph compilation
utils/mkgraph.sh data/lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2/graph
# Decoding
steps/decode_sgmm2.sh --nj 4 --cmd utils/run.pl --transform-dir exp/system1/tri3b/decode_test exp/system1/sgmm2_5b2/graph data/test exp/system1/sgmm2_5b2/decode_test
# 
steps/align_sgmm2.sh --nj 20 --cmd utils/run.pl --transform-dir exp/system1/tri3b_ali  --use-graphs true --use-gselect true data/train data/lang exp/system1/sgmm2_5b2 exp/system1/sgmm2_5b2_ali  || exit 1;

## Denlats
steps/make_denlats_sgmm2.sh --nj 20 --cmd utils/run.pl --sub-split 10  --transform-dir exp/system1/tri3b_ali data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats  || exit 1;

## SGMM+MMI
# Training
steps/train_mmi_sgmm2.sh --cmd utils/run.pl --transform-dir exp/system1/tri3b_ali --boost 0.1 data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1  || exit 1;

# Decoding
for iter in 1 2 3 4; do
        steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test data/lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it$iter
done

# Training
steps/train_mmi_sgmm2.sh --cmd utils/run.pl --transform-dir exp/tri3b_ali --boost 0.1 --zero-if-disjoint true data/train data/lang exp/system1/sgmm2_5b2_ali exp/system1/sgmm2_5b2_denlats exp/system1/sgmm2_5b2_mmi_b0.1_z
# Decoding
for iter in 1 2 3 4; do
        steps/decode_sgmm2_rescore.sh --cmd utils/run.pl --iter $iter --transform-dir exp/system1/tri3b/decode_test data/lang data/test exp/system1/sgmm2_5b2/decode_test exp/system1/sgmm2_5b2_mmi_b0.1_z/decode_test_it$iter
done

## MBR
cp -r -T exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3{,.mbr}
local/score_mbr.sh data/test data/lang exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3.mbr

## SGMM+MMI+fMMI
local/score_combine.sh data/test data/lang exp/system1/tri3b_fmmi_indirect/decode_test_it3  exp/system1/sgmm2_5b2_mmi_b0.1/decode_test_it3 exp/system1/combine_tri3b_fmmi_indirect_sgmm2_5b2_mmi_b0.1/decode_test_it8_3
echo -e "SGMM training done.\n"

#score
for x in exp/system1/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
