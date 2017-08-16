### Follow these steps to forced-aligned your transcriptions with your speech corpus 

Prerequisite: 
  * Have the Kaldi toolkit installed.
  * Have a lang directory and a train model built with Kaldi (*final.mdl* file)

#### Step 1: Forced-alignments of the transcripts corrected by a wolof speaker. Audio signals are from video elicitation (trajectory task).
steps/nnet/align.sh --nj 2 --cmd run.pl data/train data/lang exp/tri1 exp/dnn4b_pretrain-dbn_dnn_ali 

#### Step 2: Get CTM file from ali
./get_phone_train_ctm.sh ali-dir|model-dir lang-dir output-dir

#### Step 3: go to **durations_scripts/** to compute vowel durations from your corpus    


####Results are in **durations_statistics/**.
