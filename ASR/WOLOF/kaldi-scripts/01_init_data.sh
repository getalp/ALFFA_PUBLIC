#!/bin/sh

. ./path.sh

# /!\ MODIFY THE PATH TO LINK TO YOUR KALDI DIR
KALDI_DIR=$HOME/kaldi/wolof
# /!\ OR COMMENT IT AND CREATE SYMBOLIC LINKS OF utils/ and steps/
# /!\ IN YOUR CURRENT WORK DIRECTORY

#For more information about the format, please refer to Kaldi website http://kaldi.sourceforge.net/data_prep.html

#### build text file, utt2spk file and spk2utt ####
echo "make utt2spk and spk2utt for train dev test..."
for dir in data/train data/dev data/test
do
  pushd $dir
    cat text | cut -d' ' -f1 > utt
    cat text | cut -d'_' -f2 > spk
    paste utt spk > utt2spk
    $KALDI_DIR/utils/utt2spk_to_spk2utt.pl utt2spk | sort -k1 > spk2utt
    rm utt spk
  popd
done
echo -e "utt2spk and spk2utt created for train dev test.\n"

#### compute MFCC ####
## first create the file wav.scp in train, test and dev directories
echo "make wav.scp for train dev test..."
for dir in data/train data/dev data/test
do
  pushd $dir
    ls */*.wav |  sed 's/^/data\/'$dir'\//g' > tutu1  #The path of wav files in wav.scp have to be modified to point to the actual location 
    cat tutu1 | cut -d'/' -f4 | sed 's/.wav//g' > tutu2 #modify the number of field to cut (depending the path you set previously)
    paste tutu2 tutu1 > wav.scp
    rm tutu2 tutu1
  popd
done
echo -e "wav.scp created for train dev test.\n"

## compute mfcc
echo "compute mfcc for train dev test..."

for dir in data/train data/dev data/test
do
  $KALDI_DIR/steps/make_mfcc.sh --nj 4 $dir log mfcc
  $KALDI_DIR/steps/compute_cmvn_stats.sh $dir log mfcc
done
echo -e "compute mfcc done.\n"
