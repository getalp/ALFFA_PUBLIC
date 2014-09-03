#!/bin/sh

. ./00_init_paths.sh


cd $WORK_DIR


####build text file########
echo "make text for $TRAIN_DIR $EXP_DIR"

pushd ~/kaldi/data/train #put the path of the directory which contains the data for training
#the input file is containing all the transcriptions of your data train
cat trsTrain.txt | awk 'BEGIN {FS="("} {print $2 " "tolower($1)}' | sed 's/)//g' | sed 's/<s>//g' | sed 's/<\/s>//g' | sed 's/.*/\L&/' | sed 's/ha/HA/g' | sort | uniq > text
popd


pushd ~/kaldi/data/test #put the path of the directory which contains the data for test
#the input file is containing all the transcriptions of your data test
cat trsTest.txt | awk 'BEGIN {FS="("} {print $2 " "tolower($1)}' | sed 's/)//g' | sed 's/<s>//g' | sed 's/<\/s>//g' | sed 's/.*/\L&/' | sed 's/ha/HA/g' | sort | uniq > text
popd


pushd ~/kaldi/data/dev #put the path of the directory which contains the data for experimentation
#the input file is containing all the transcriptions of your data dev
cat trsDev.txt | awk 'BEGIN {FS="("} {print $2 " "tolower($1)}' | sed 's/)//g' | sed 's/<s>//g' | sed 's/<\/s>//g' | sed 's/.*/\L&/' | sed 's/ha/HA/g' | sort | uniq > text
popd


#####build utt2spk file and spk2utt ##########
echo "make utt2spk and spk2utt for $TRAIN_DIR $EXP_DIR"

pushd ~/kaldi/data/train #put the path of the directory which contains the previous file "text" created for training
cat text | awk 'BEGIN {FS=" "} {print $1}' > toto1
cat toto1 | sed -e 's/HA//g' | cut -d'_' -f1 | sed '$d' > toto2
paste toto1 toto2 | sort | uniq > utt2spk
$KALDI_DIR/egs/wsj/s5/utils/utt2spk_to_spk2utt.pl utt2spk | sort -k1 > spk2utt
rm toto2 toto1
popd

pushd ~/kaldi/data/test #put the path of the directory which contains the previous file "text" created for test
cat text | awk 'BEGIN {FS=" "} {print $1}' > toto1
cat toto1 | sed -e 's/HA//g' | cut -d'_' -f1 | sed '/^$/d' > toto2
paste toto1 toto2 | sort | uniq > utt2spk
$KALDI_DIR/egs/wsj/s5/utils/utt2spk_to_spk2utt.pl utt2spk | sort -k1 > spk2utt
rm toto2 toto1
popd

pushd ~/kaldi/data/dev #put the path of the directory which contains the previous file "text" created for experimentation
cat text | awk 'BEGIN {FS=" "} {print $1}' > toto1
cat toto1 | sed -e 's/HA//g' | cut -d'_' -f1 | sed '/^$/d' > toto2
paste toto1 toto2 | sort | uniq > utt2spk
$KALDI_DIR/egs/wsj/s5/utils/utt2spk_to_spk2utt.pl utt2spk | sort -k1 > spk2utt
rm toto2 toto1
popd



##### compute MFCC ####

###first create the file wav.scp in train, test and dev directories
echo "make wav.scp for $TRAIN_DIR $EXP_DIR"

pushd ~/kaldi/data/train #put the path of the directory which contains the audio data you will use for training
ls */*.wav |  sed 's/^/\/home\/gauthier\/kaldi\/data\/train\//g' > tutu1
cat tutu1 | sed "s/\//#/g" | awk 'BEGIN{FS="#"} {print $8}' | sed "s/\.wav//g" > tutu2
paste tutu2 tutu1 > wav.scp
rm tutu2 tutu1
popd

pushd ~/kaldi/data/dev #put the path of the directory which contains the audio data you will use for experimentation
ls */*.wav |  sed 's/^/\/home\/gauthier\/kaldi\/data\/dev\//g' > tutu1
cat tutu1 | sed "s/\//#/g" | awk 'BEGIN{FS="#"} {print $8}' | sed "s/\.wav//g" > tutu2
paste tutu2 tutu1 > wav.scp
rm tutu2 tutu1
popd

pushd ~/kaldi/data/test #put the path of the directory which contains the audio data you will use for test
ls */*.wav |  sed 's/^/\/home\/gauthier\/kaldi\/data\/test\//g' > tutu1
cat tutu1 | sed "s/\//#/g" | awk 'BEGIN{FS="#"} {print $8}' | sed "s/\.wav//g" > tutu2
paste tutu2 tutu1 > wav.scp
rm tutu2 tutu1
popd


###compute mfcc
echo "compute mfcc for $TRAIN_DIR $EXP_DIR"

pushd ~/kaldi/data #put the path of the directory which contains the 3 corpus (train, dev, test)
for dir in $TRAIN_DIR $EXP_DIR
        do
                $KALDI_DIR/egs/wsj/s5/steps/make_mfcc.sh --nj 4 $dir log  mfcc
                $KALDI_DIR/egs/wsj/s5/steps/compute_cmvn_stats.sh $dir log mfcc
        done
popd

####end compute MFCC