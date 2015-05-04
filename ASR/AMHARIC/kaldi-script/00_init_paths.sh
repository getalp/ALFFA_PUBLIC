#!/bin/sh

#### Initialization of variables
#### to make easier the comprehension
#### and the execution
#### of the Kaldi scripts


DATA_DIR=/home/melese/kaldi/data #put the path of the directory where are the audio data
WORK_DIR=/home/melese/kaldi #put the path of the main directory where are all the Kaldi scripts for training and decoding
KALDI_DIR=/home/melese/kaldi-trunk #put the path of the directory where Kaldi toolkit is installed
LEXICON=/home/melese/kaldi/data/lexicon.txt #put the path of the acoustic dictionnary
EXP_DIR="test" #put the name of the directories where are the experimental data and the test data
TRAIN_DIR="train" #put the name of the directory where are the training data

TRAIN_EXP_DIR=/home/melese/kaldi/exp/System1 #put the path of the directory which will contain your ASR system



PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/onlinebin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst-1.3.4/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:$KALDI_DIR/src/nnet-cpubin:$KALDI_DIR/src/onlinebin:$KALDI_DIR/src/nnet2bin:$WORK_DIR/conf:$KALDI_DIR/src/nnetbin:$KALDI_DIR/src/kwsbin:$KALDI_DIR/src/online2bin/:$KALDI_DIR/src/ivectorbin/:


#PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst-1.3.4/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:/home/lecouteu/kaldi-trunk/src/nnet-cpubin/:



export LC_ALL=C

cd $WORK_DIR


