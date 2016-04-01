#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi/wolof
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

#convert to FST format for Kaldi
cat lang/combineV1-web-W0.9-3gram.arpa | ./utils/find_arpa_oovs.pl lang/words.txt  > lang/oovs.txt
cat lang/combineV1-web-W0.9-3gram.arpa | \
  grep -v '<s> <s>' | \
  grep -v '</s> <s>' | \
  grep -v '</s> </s>' | \
  $KALDI_DIR/src/bin/arpa2fst - | $KALDI_DIR/tools/openfst-1.3.4/bin/fstprint | \
  $KALDI_DIR/utils/remove_oovs.pl lang/oovs.txt | \
  $KALDI_DIR/utils/eps2disambig.pl | $KALDI_DIR/utils/s2eps.pl | $KALDI_DIR/tools/openfst-1.3.4/bin/fstcompile --isymbols=lang/words.txt \
  --osymbols=lang/words.txt  --keep_isymbols=false --keep_osymbols=false | \
  $KALDI_DIR/tools/openfst-1.3.4/bin/fstrmepsilon > lang/G.fst

#if prep_lang.sh returns G.fst is not ilabel sorted, run this to sort
fstarcsort --sort_type=ilabel lang/G.fst > lang/G_new.fst
mv lang/G_new.fst lang/G.fst
