#!/bin/sh

. ./kaldi-scripts/00_init_paths.sh  || { echo -e "\n00_init_paths.sh expected.\n"; exit; } 

#We use a LM with %PPL=164 
#convert to FST format for Kaldi
cat ./LM/fongbe.arpa | ./utils/find_arpa_oovs.pl data/lang/words.txt  > LM/oovs.txt
cat ./LM/fongbe.arpa |    \
    grep -v '<s> <s>' | \
    grep -v '</s> <s>' | \
    grep -v '</s> </s>' | \
    arpa2fst - | fstprint | \
    utils/remove_oovs.pl LM/oovs.txt | \
    utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang/words.txt \
      --osymbols=data/lang/words.txt  --keep_isymbols=false --keep_osymbols=false | \
     fstrmepsilon > ./data/lang/G.fst

#if prep_lang.sh returns G.fst is not ilabel sorted, run this to sort
fstarcsort --sort_type=ilabel data/lang/G.fst > data/lang/G_new.fst
mv data/lang/G_new.fst data/lang/G.fst


