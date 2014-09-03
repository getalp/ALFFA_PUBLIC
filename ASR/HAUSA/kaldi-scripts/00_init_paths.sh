#!/bin/sh

#### Initialization of variables
#### to make easier the comprehension
#### and the execution
#### of the Kaldi scripts


DATA_DIR=/home/gauthier/kaldi/data #put the path of the directory where are the audio data
WORK_DIR=/home/gauthier/kaldi #put the path of the main directory where are all the Kaldi scripts for training and decoding
KALDI_DIR=/home/lecouteu/kaldi-trunk #put the path of the directory where Kaldi toolkit is installed
LEXICON=/home/gauthier/kaldi/data/lexicon.txt #put the path of the acoustic dictionnary
EXP_DIR="dev test" #put the name of the directories where are the experimental data and the test data
TRAIN_DIR="train" #put the name of the directory where are the training data

TRAIN_EXP_DIR=/home/gauthier/kaldi/exp/system1 #put the path of the directory which will contain your ASR system

#for reinitialized your environment variables for Kaldi
PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst-1.3.4/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:/home/lecouteu/kaldi-trunk/src/nnet-cpubin/:


export LC_ALL=C

cd $WORK_DIR


