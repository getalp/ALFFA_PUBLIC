#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

#We use a LM with %PPL=164 


#convert to FST format for Kaldi
cat ./LM/swahili.arpa | ./utils/find_arpa_oovs.pl lang/words.txt  > LM/oovs.txt
cat ./LM/swahili.arpa |    \
    grep -v '<s> <s>' | \
    grep -v '</s> <s>' | \
    grep -v '</s> </s>' | \
    /home/tan/kaldi-trunk/src/bin/arpa2fst - | /home/tan/kaldi-trunk/tools/openfst-1.3.2/bin/fstprint | \
    utils/remove_oovs.pl LM/oovs.txt | \
    utils/eps2disambig.pl | utils/s2eps.pl | /home/tan/kaldi-trunk/tools/openfst-1.3.2/bin/fstcompile --isymbols=lang/words.txt \
      --osymbols=lang/words.txt  --keep_isymbols=false --keep_osymbols=false | \
     /home/tan/kaldi-trunk/tools/openfst-1.3.2/bin/fstrmepsilon > ./lang/G.fst

