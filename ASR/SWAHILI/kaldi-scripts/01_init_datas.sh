#!/bin/sh

. ./00_init_paths.sh  || die "00_init_paths.sh expected";

echo "make text, segments, spk2utt, utt2spk files for $TRAIN_DIR $EXP_DIR"
echo "*******"
####build text file########


####build segments file#######


#####build utt2spk file and spk2utt ##########
#####bild wav.scp ****


####compute MFCC
###first create the file wav.scp in train and test directories

###compute MFCC
pushd /home/tan/kaldi/swahili
#steps/make_mfcc.sh --nj 4 data/train data/log/train  mfcc
#steps/compute_cmvn_stats.sh data/train data/log/train mfcc
steps/make_mfcc.sh --nj 4 data/test data/log/test  mfcc
steps/compute_cmvn_stats.sh data/test data/log/test mfcc
popd
#end compute MFCC















