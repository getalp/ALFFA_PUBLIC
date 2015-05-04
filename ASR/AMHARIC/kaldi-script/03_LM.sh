#!/bin/sh

. ./00_init_paths.sh

#Creating a Language model data of arpa type

#/home/melese/toolkit/srilm/bin/add-start-end.sh < amharic.lm.data.Unique > amharic.lm.data.uniq.sorted

/home/melese/toolkit/srilm/bin/i686-m64/ngram-count -order 5 -text lm/amharic.lm.data.segmented -lm lm/amharic.train.lm.data.arpa -unk -kndiscount1 -kndiscount2 -kndiscount3 -kndiscount4 -kndiscount5 -gt1min 1 -gt2min 1 -gt3min 1 -gt4min 1 -gt5min 1

#convert to FST format for Kaldi
cat lm/amharic.train.lm.data.arpa | ./utils/find_arpa_oovs.pl lang/words.txt  > lang/oovs.txt

cat lm/amharic.train.lm.data.arpa | grep -v '<s> <s>' | grep -v '</s> <s>' | grep -v '</s> </s>' | $KALDI_DIR/src/bin/arpa2fst - | $KALDI_DIR/tools/openfst-1.3.4/bin/fstprint | $KALDI_DIR/egs/wsj/s5/utils/remove_oovs.pl lang/oovs.txt | $KALDI_DIR/egs/wsj/s5/utils/eps2disambig.pl | $KALDI_DIR/egs/wsj/s5/utils/s2eps.pl | $KALDI_DIR/tools/openfst-1.3.4/bin/fstcompile --isymbols=lang/words.txt --osymbols=lang/words.txt  --keep_isymbols=false --keep_osymbols=false | $KALDI_DIR/tools/openfst-1.3.4/bin/fstrmepsilon > lm/G.fst

#add fst sort arc tools/openfst/bin/arcsort to solve the problem of "ERROR: data/lang/G.fst is not ilabel sorted"
fstarcsort  --sort_type=ilabel lm/G.fst lm/newG.fst
mv lm/newG.fst lang/
mv lang/newG.fst lang/G.fst
#utils/validate_lang.pl lang
