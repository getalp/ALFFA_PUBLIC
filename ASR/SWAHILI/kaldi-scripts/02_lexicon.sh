#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

touch lang/dict/extra_questions.txt

# remove the lexiconp.txt file if exist, else it won't be updated
rm lang/dict/lexiconp.txt


#lexicon.txt
#+ add silence entries into the lexicon + add <UNK> with a "garbage" phone
echo "!SIL SIL" > lang/dict/lexicon.txt
echo "<UNK> SPN" >> lang/dict/lexicon.txt
echo "<laughter> LAU" >> lang/dict/lexicon.txt
echo "<music> MUS" >> lang/dict/lexicon.txt
cat /home/tan/kaldi/swahili/lang/dict/swahili_train.dict >> /home/tan/kaldi/swahili/lang/dict/lexicon.txt


echo "SIL" >  lang/dict/optional_silence.txt
echo "<UNK>" > lang/oov.txt
echo "SIL" > lang/dict/silence_phones.txt
echo "SPN" >> lang/dict/silence_phones.txt

echo "LAU" >>  lang/dict/silence_phones.txt
echo "MUS" >>  lang/dict/silence_phones.txt

cp lang/dict/swahili.phone  lang/dict/nonsilence_phones.txt


utils/prepare_lang.sh lang/dict/ "<UNK>" lang/tmp/ lang/
