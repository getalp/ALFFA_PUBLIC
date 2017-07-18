#!/bin/bash

##
# Create and prepare the dict/ directory
# Once the script ran, dict/ directory will contain:
# lexicon.txt, nonsilence_phones, silence_phones.txt, optional_silence.txt
##

mkdir -p data/local/dict
pushd data/local/dict

##create nonsilence_phones.txt
cat ../lexicon.txt | awk '{for (i=2;i<=NF;i++) print $i}' | sort -u > nonsilence_phones.txt

##create silence_phones.txt
echo "SIL" > silence_phones.txt
##extra_questions.txt
touch extra_questions.txt

##lexicon.txt
rm -f lexicon.txt # if run twice, don't append to old one
cat ../lexicon.txt | sed 's/(.)//' > lexicon.txt

##write UNK symbol
echo -e "SIL\tSIL" >> lexicon.txt
echo -e "<UNK>\tSIL" >> lexicon.txt
echo "SIL" > optional_silence.txt
