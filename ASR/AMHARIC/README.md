## Amharic speech data Acquired from Solomon T. and Martha Y.
## Prepared by 
### Michael Melese (Addis Ababa University, Ethiopia)
### Laurent Besacier, ELodie Gauthier (GETALP LIG, Grenoble, France)
### Million Meshesha (Addis Ababa University, Ethiopia)


#### OVERVIEW
The package contains Amharic speech corpus with audio data in the directory /data. The data directory contains 2 subdirectories:
a. train - speech data and transription for training automatic speech recognition Kaldi ASR format [1]
b. test - speech data and transription for testing automatic speech recognition Kaldi ASR format

A text corpus and language model in the directory /LM, and lexicon in the directory /lang

### Amharic SPEECH CORPUS
Directory: /data/train
Files: text (training transcription), wav.scp (file id and path), utt2spk (file id and audio id), spk2utt (audio id and file id), wav (.wav files). 
For more information about the format, please refer to Kaldi website http://kaldi.sourceforge.net/data_prep.html
Description: training data in Kaldi format about 20 hours. Note: The path of wav files in wav.scp have to be modified to point to the actual locatiion.  

Directory: /data/test
Files: text (test transcription), wav.scp (file id and path), utt2spk (file id and audio id), spk2utt (audio id and file id), wav (.wav files)
Description: testing data in Kaldi format about 2 hours. The audio files for testing has the format 

### Amharic TEXT CORPUS
Directory: /lm
Files: amharic_lm_PART1.zip, amharic_lm_PART2.zip
Those files have to be unzipped and reassembled in one file to constitute the original language model "amharic.train.lm.data.arpa".
This language model is created using SRILM using 3-grams ; the text is segmented in morphemes using morfessor 2.0 [2][3] 

### LEXICON/PRONUNCIATION DICTIONARY
Directory: /lang
Files: lexicon.txt (lexicon), nonsilence_phones.txt (speech phones), optional_silence.txt (silence phone)
Description: lexicon contains words and their respective pronunciation, non-speech sound and noise in Kaldi format ; the tokens have been extracted after morpheme level segmentation using morfessor 2.0.[3]

### SCRIPTS
in /kaldi-scripts you find the scripts used to train and test models
(path has to be changed to make it work in your own directory for 00_init_paths.sh and 01_init_datas.sh (don't forget to set the appropriate path for test.pl and train.pl)) and from the existing data and lang directory you can directly start run the sequence : 
04_train_mono.sh 
	change the size --beam and retry beam --retry-beam using slightly wider beams side as per the following specification in kaldi script of mono_train.sh for this corpus (i.e beam size from  --beam=$[$beam]  to --beam=$[$beam*4] and retry-beam size from --retry-beam=$[$beam*4] to --retry-beam=$[$beam*22])

04a_train_triphone.sh + 04b_train_MLLT_LDA.sh + 04c_train_SAT_FMLLR.sh + 04d_train_MMI_FMMI.sh + 04e_train_sgmm.sh



### THE FOLLOWING RESULTS OBTAINED SO FAR (you should obtain the same result on this data if same protocol used)

######## MER stands for Morpheme Error Rate
######## SER stands for Sentence Error Rate
######## CER stands for Character Error Rate per utterance [4]
Monophone (13 MFCC)
---- %MER 19.89 [ 1234 / 6203, 91 ins, 362 del, 781 sub ]
---- %SER 80.78 [ 290 / 359 ]
---- %CER 15.02

Triphone (13 MFCC)

---- %MER 10.83 [ 672 / 6203, 71 ins, 156 del, 445 sub ]
---- %SER 62.12 [ 223 / 359 ]
---- %CER 6.94

Triphone (13 MFCC + delta + delta2)

---- %WER 9.62 [ 597 / 6203, 94 ins, 106 del, 397 sub ]
---- %SER 60.45 [ 217 / 359 ]
---- %CER 6.46

Triphone (39 features) with LDA+MLLT

---- %WER 8.61 [ 534 / 6203, 76 ins, 101 del, 357 sub ]
---- %SER 56.27 [ 202 / 359 ]
---- %CER 5.34

Triphone (39 features) SAT+FMLLR

---- %WER 9.24 [ 573 / 6203, 86 ins, 109 del, 378 sub ]
---- %SER 59.89 [ 215 / 359 ]
---- %CER 6.27

Triphone (39 features) MMI
---- %MER 10.83 [ 672 / 6203, 85 ins, 157 del, 430 sub ]
---- %SER 64.07 [ 230 / 359 ]
---- %CER 7.66

Triphone (39 features) fMMI + mmi with indirect differential

Iteration 3
---- %MER 10.56 [ 655 / 6203, 80 ins, 154 del, 421 sub ]
---- %SER 64.62 [ 232 / 359 ]
---- %CER 7.13
Iteration 4
---- %MER 10.59 [ 657 / 6203, 75 ins, 162 del, 420 sub ]
---- %SER 64.90 [ 233 / 359 ]
---- %CER 7.31
Iteration 5
---- %MER 10.37 [ 643 / 6203, 81 ins, 145 del, 417 sub ]
---- %SER 63.51 [ 228 / 359 ]
---- %CER 7.07
Iteration 6
---- %MER 10.45 [ 648 / 6203, 83 ins, 147 del, 418 sub ]
---- %SER 64.07 [ 230 / 359 ]
---- %CER 7.21
Iteration 7
---- %MER 10.35 [ 642 / 6203, 79 ins, 147 del, 416 sub ]
---- %SER 64.62 [ 232 / 359 ]
---- %CER 7.05
Iteration 8
---- %MER 10.43 [ 647 / 6203, 79 ins, 155 del, 413 sub ]
---- %SER 64.62 [ 232 / 359 ]
---- %CER 7.34

Triphone (39 features) SGMM
---- %MER 8.75 [ 543 / 6203, 52 ins, 134 del, 357 sub ]
---- %SER 57.10 [ 205 / 359 ]
---- %CER 5.50

Triphone (39 features) SGMM+MMI
Iteration 1
---- %MER 8.59 [ 533 / 6203, 46 ins, 131 del, 356 sub ]
---- %SER 55.71 [ 200 / 359 ]
---- %CER 5.47
Iteration 2
---- %MER 8.48 [ 526 / 6203, 51 ins, 122 del, 353 sub ]
---- %SER 54.60 [ 196 / 359 ]
---- %CER 5.38
Iteration 3
---- %MER 8.43 [ 523 / 6203, 51 ins, 125 del, 347 sub ]
---- %SER 55.15 [ 198 / 359 ]
---- %CER 5.45
Iteration 4
---- %MER 8.59 [ 533 / 6203, 51 ins, 130 del, 352 sub ]
---- %SER 55.99 [ 201 / 359 ]
---- %CER 5.57


====IMPORTANT=========
If you use this data, please cite the following paper for the ressources

@article{tachbelie2014,
	Author = {Martha Tachbelie and Solomon Teferra Abate and Laurent Besacier},
	Date-Added = {2015-04-14 08:08:31 +0000},
	Date-Modified = {2015-04-14 10:56:28 +0000},
	Journal = {Speech Communication},
	Publisher = {Elsevier},
	Title = {Using different acoustic, lexical and language modeling units for ASR of an under-resourced language - Amharic},
	Volume = {56},
	Year = {2014}}

as well as the following repository for the ASR system: https://github.com/besacier/ALFFA_PUBLIC/tree/master/ASR


#### REFERENCES
[1] KALDI: http://kaldi.sourceforge.net/tutorial_running.html
[2] SRILM: http://www.speech.sri.com/projects/srilm/ 
[3] Mathias Creutz and Krista Lagus. Unsupervised discovery of morphemes. In Proceedings of the Workshop on Morphological and Phonological Learning of ACL-02, pages 21-30, Philadelphia, Pennsylvania, 11 July, 2002.
[4] Stoyan Mihov, Svetla Koeva, Christoph Ringlstetter, Klaus U. Schulz and Christian Strohmaier: Precise and Efficient Text Correction using Levenshtein Automata, Dynamic Web Dictionaries and Optimized Correction Models. Proceedings of the Workshop on International Proofing Tools and Language Technologies, Patras, 2004.
