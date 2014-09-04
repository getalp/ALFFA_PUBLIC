#Author: Tien-Ping Tan
#Create folders in the training/testing script: data/forced-alignment, data/forced-alignment/mfcc, data/forced-alignment/log
#Prerequisite: put spk2utt, utt2spk, text, wav.scp at data/forced-alignment directory

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

#1. Convert text transcription (for force aligment) to id based transcription
#text for force alignment resides in data/forced-alignment/text
utils/sym2int.pl -f 2- lang/words.txt < data/forced-alignment/text > data/forced-alignment/syn.tra

#2. Create fst graph for the test transcription (force alignment)
#Select either 39 features or 39+1 features mdf acoustic model
#2a. 39 features
compile-train-graphs /home/tan/kaldi/syn2/exp/system1/tri2a/tree /home/tan/kaldi/syn2/exp/system1/tri2a/final.mdl lang/L.fst ark:data/forced-alignment/syn.tra ark:data/forced-alignment/graphs.fsts

#2b. 39 features + 1 transform feature
#compile-train-graphs /home/tan/kaldi/syn/exp/system1/tri3b/tree /home/tan/kaldi/syn/exp/system1/tri3b/final.mdl lang/L.fst ark:data/forced-alignment/syn.tra ark:data/forced-alignment/graphs.fsts

#3. compute MFCC - 13 features
#steps/make_mfcc.sh --nj 4 data/forced-alignment data/forced-alignment/log  data/forced-alignment/mfcc
#steps/compute_cmvn_stats.sh data/forced-alignment data/forced-alignment/log data/forced-alignment/mfcc

#MFCC + delta2 
#3a. Using 39 features
#apply-cmvn --norm-vars=false --utt2spk=ark:data/forced-alignment/utt2spk scp:data/forced-alignment/cmvn.scp scp:data/forced-alignment/feats.scp ark:- | add-deltas ark:- ark:- > data/forced-alignment/feats2.scp

#MFCC + delta2 + transform features
#3b. Using 39 features + 1 transform features
#apply-cmvn --norm-vars=false --utt2spk=ark:data/forced-alignment/utt2spk scp:data/forced-alignment/cmvn.scp scp:data/forced-alignment/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- | transform-feats /home/tan/kaldi/syn/exp/system1/tri3b/final.mat ark:- ark:- > data/forced-alignment/feats2.scp


#4. Forced alignment
#4a. 39 features 
gmm-align-compiled /home/tan/kaldi/syn2/exp/system1/tri2a/final.mdl ark:data/forced-alignment/graphs.fsts ark,s,cs:data/forced-alignment/feats2.scp ark:data/forced-alignment/syn.ali

#4b. 39 features + 1 transform feature
#gmm-align-compiled /home/tan/kaldi/syn/exp/system1/tri3b/final.mdl ark:data/forced-alignment/graphs.fsts ark,s,cs:data/forced-alignment/feats2.scp ark:data/forced-alignment/syn.ali

#5. Convert alignment to a different format
echo output alignment to data/forced-alignment/alignment.phoneseg
ali-to-phones --write-lengths /home/tan/kaldi/syn2/exp/system1/tri2a/final.mdl ark:data/forced-alignment/syn.ali ark,t:data/forced-alignment/alignment.phoneseg
