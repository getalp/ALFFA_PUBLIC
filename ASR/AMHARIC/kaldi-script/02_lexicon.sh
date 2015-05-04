#!/bin/sh

. 00_init_paths.sh 
rm -r lang
mkdir lang
mkdir lang/dict


#create nonsilence_phones.txt
cat $LEXICON | awk '{for (i=2;i<=NF;i++) print $i}' | sort -u > lang/dict/nonsilence_phones.txt
#+remove last lines

#create silence_phones.txt
#done manually  !!!!! UH is a phoneme code => use UHH instead !!!

#extra_questions.txt
touch lang/dict/extra_questions.txt

#lexicon.txt
cat $LEXICON | sed 's/(.)//' > lang/dict/lexicon.txt
#IMPORTANT for the prepare_lang.sh step: add silence entries + add <UNK> with a "garbage" phone into the lexicon

echo "SIL	SIL" >>  lang/dict/lexicon.txt
echo "<UNK>	UNK" >>  lang/dict/lexicon.txt
echo "<unk>     unk" >>  lang/dict/lexicon.txt
echo "SIL" >  lang/dict/optional_silence.txt

echo "<UNK>" > lang/oov.txt

echo "BREATH" > lang/dict/silence_phones.txt
echo "COUGH" >> lang/dict/silence_phones.txt
echo "NOISE" >> lang/dict/silence_phones.txt
echo "SMACK" >> lang/dict/silence_phones.txt
echo "UHH" >> lang/dict/silence_phones.txt
echo "UM" >> lang/dict/silence_phones.txt
echo "SPN" >> lang/dict/silence_phones.txt
echo "SIL" >> lang/dict/silence_phones.txt
echo "UNK" >> lang/dict/silence_phones.txt
echo "unk" >> lang/dict/silence_phones.txt

#prepare_lang.sh step
$KALDI_DIR/egs/wsj/s5/utils/prepare_lang.sh lang/dict "<UNK>" lang/tmp lang
