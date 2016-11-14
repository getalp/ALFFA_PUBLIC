#!/bin/bash

##
# Create and prepare the dict/ directory
# Once the script ran, dict/ directory will contain:
# lexicon.txt, nonsilence_phones, silence_phones.txt, optional_silence.txt
##

mkdir -p data/local/dict
pushd data/local/dict


#lexicon.txt file creation
rm -f lexicon.txt # if run twice, don't append to old one
while read -r ligne; do  
  echo -e "$ligne $(echo -e $ligne | sed -r 's/([^ ])/\1 /g')" >> lexicon.txt
done < ../fongbe_wordlist.txt 
#write UNK symbol (useful for Kaldi)
sed -i '1i<UNK> SPN' lexicon.txt
sed -i '1i!SIL SIL' lexicon.txt

#nonsilence_phones.txt file creation
sed -n '3,$ p' lexicon.txt | awk '{for (i=2;i<=NF;i++) print $i}' | sort -u > nonsilence_phones.txt
#echo -e "ɖ" >> nonsilence_phones.txt
#echo -e "a" >> nonsilence_phones.txt
#echo -e "ε" >> nonsilence_phones.txt
#echo -e "ɔ" >> nonsilence_phones.txt
#echo -e "i" >> nonsilence_phones.txt
#echo -e "b" >> nonsilence_phones.txt
#echo -e "c" >> nonsilence_phones.txt
#echo -e "d" >> nonsilence_phones.txt
#echo -e "e" >> nonsilence_phones.txt
#echo -e "f" >> nonsilence_phones.txt
#echo -e "g" >> nonsilence_phones.txt
#echo -e "h" >> nonsilence_phones.txt
#echo -e "j" >> nonsilence_phones.txt
#echo -e "k" >> nonsilence_phones.txt
#echo -e "l" >> nonsilence_phones.txt
#echo -e "m" >> nonsilence_phones.txt
#echo -e "n" >> nonsilence_phones.txt
#echo -e "o" >> nonsilence_phones.txt
#echo -e "p" >> nonsilence_phones.txt
#echo -e "r" >> nonsilence_phones.txt
#echo -e "s" >> nonsilence_phones.txt
#echo -e "t" >> nonsilence_phones.txt
#echo -e "u" >> nonsilence_phones.txt
#echo -e "v" >> nonsilence_phones.txt
#echo -e "w" >> nonsilence_phones.txt
#echo -e "x" >> nonsilence_phones.txt
#echo -e "y" >> nonsilence_phones.txt
#echo -e "z" >> nonsilence_phones.txt

#optional_silence.txt file creation
echo -e "SIL" >> optional_silence.txt

#silence_phones.txt file creation
echo -e "SIL" >> silence_phones.txt
echo -e "SPN" >> silence_phones.txt

popd
