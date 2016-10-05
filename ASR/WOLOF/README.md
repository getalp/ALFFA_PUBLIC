## Wolof Data collected by Elodie Gauthier & Pascal Uriel Elingui 
## Prepared by Elodie Gauthier & Laurent Besacier
### GETALP LIG, Grenoble, France & Voxygen SAS, Dakar, Sénégal     

#### OVERVIEW
The package contains Wolof speech corpus with audio data in the directory *data/*. The data directory contains 3 subdirectories:    
1. **train** - speech data and transcription for training automatic speech recognition system (Kaldi ASR format [1])    
2. **dev** - speech data and transcription (verified) to evaluate the ASR system (Kaldi ASR format)    
3. **test** - speech data and transcription (verified) for testing the ASR system (Kaldi ASR format)    
4. **dev_unverified** - original speech data and transcription (NOT verified, contains mispronunciations)        
5. **test_unverified** - original speech data and transcription (NOT verified, contains mispronunciations)    

*LM/* directory contains 2 text corpus and the language model.

The package contains also 2 *lang/* directories to build whether an ASR system without vowel length contrast modelling whether with vowel length contrast modelling.    
1. **lang_o3g_NoLengthContrast** - contains the lexicon without vowel length tag    
2. **lang_o3g_LengthContrast**  - contains the lexicon with the vowel length tag

#### PUBLICATION ON WOLOF SPEECH & LM DATA
More details on the corpus and how it was collected can be found on the following publication (please cite this bibtex if you use this data).    
  @inproceedings{gauthier2016collecting,
  	title={Collecting resources in sub-saharan african languages for automatic speech recognition: a case study of wolof},
  	author={Gauthier, Elodie and Besacier, Laurent and Voisin, Sylvie and Melese, Michael and Elingui, Uriel Pascal},
  	year={2016},
  	organization={LREC}}     
 
More details on the vowel length contrast modelling can be found on the following publication (please cite this bibtex if you use this data).   
   @article{gauthier2016automatic,
  	title={Automatic Speech Recognition for African Languages with Vowel Length Contrast},
  	author={Gauthier, Elodie and Besacier, Laurent and Voisin, Sylvie},
  	journal={Procedia Computer Science},
  	volume={81},
  	pages={136--143},
  	year={2016},
  	publisher={Elsevier}}   
	
### SCRIPTS
1. In *kaldi-scripts/* you will find the scripts used to train and test models
(PATH variable has to be changed to make it work in your own directory!)
from the existing data and lang directory you can directly start run the sequence : 04\_train\_mono.sh + 04a\_train\_triphone.sh + 04b\_train\_MLLT\_LDA.sh + 04c\_train\_SAT\_FMLLR.sh + 04d\_train\_MMI\_FMMI.sh + 04e\_train\_sgmm.sh + 05\_train\_dnn.sh    
ASR system WITHOUT vowel length contrast has been taking as example in the scripts.    
For more information about the format, please refer to Kaldi website http://kaldi-asr.org/doc/data_prep.html     
2. In *useful_scripts/* you will find some scripts you can use if you desire calculate the CER of your ASR system.        

### WER RESULTS OBTAINED SO FAR 
##### (you should obtain the same on these data if same protocol used)

######           +++ WITHOUT vowel length duration modelling +++

 
Acoustic models        | WER score *(%)* on **dev**  | WER score *(%)* on **test**      |
:--------------------- |:-----------------------------------:| :--------------------------------------:|
Triphone *(13 MFCC)*   |                 25.2                |                 27.6                    |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI |     22.0       |        25.1                    |
DNNs + sMBR            |                `20.5`               |                `24.9`                   |
 

###### +++ WITH vowel length duration modelling (only /a/, /e/, /E/, /o/, and /O/) +++

 
Acoustic models        | WER score *(%)* on **dev**  | WER score *(%)* on **test**       |
:--------------------- |:-----------------------------------:| :---------------------------------------:|
Triphone *(13 MFCC)*   |                 25.1                |                  27.9                    |
DNNs + sMBR            |                `20.0                |                 `24.5`                   |


#### REFERENCES
[1] KALDI: http://kaldi.sourceforge.net/tutorial_running.html
