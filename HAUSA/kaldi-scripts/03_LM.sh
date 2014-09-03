#!/bin/sh

. ./00_init_paths.sh

$LM = LM/HAU.3gram_Tolower.arpa  #put the path where is your language model

#convert to FST format for Kaldi
cat $LM | ./utils/find_arpa_oovs.pl lang/words.txt  > lang/oovs.txt
cat $LM |    \
    grep -v '<s> <s>' | \
    grep -v '</s> <s>' | \
    grep -v '</s> </s>' | \
    $KALDI_DIR/src/bin/arpa2fst - | $KALDI_DIR/tools/openfst-1.3.4/bin/fstprint | \
    $KALDI_DIR/egs/wsj/s5/utils/remove_oovs.pl lang/oovs.txt | \
    $KALDI_DIR/egs/wsj/s5/utils/eps2disambig.pl | $KALDI_DIR/egs/wsj/s5/utils/s2eps.pl | $KALDI_DIR/tools/openfst-1.3.4/bin/fstcompile --isymbols=lang/words.txt \
      --osymbols=lang/words.txt  --keep_isymbols=false --keep_osymbols=false | \
     $KALDI_DIR/tools/openfst-1.3.4/bin/fstrmepsilon > ./lang/G.fst

