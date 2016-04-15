## Wolof Data collected by Elodie Gauthier & Pascal Uriel Elingui 
## Prepared by Elodie Gauthier & Laurent Besacier
### GETALP LIG, Grenoble, France & Voxygen SAS, Dakar, Sénégal     

#### OVERVIEW
The package contains Wolof speech corpus with audio data in the directory *data/*. The data directory contains 3 subdirectories:    
1. **train** - speech data and transcription for training automatic speech recognition system (Kaldi ASR format [1])    
2. **dev** - speech data and transcription to evaluate the ASR system (Kaldi ASR format)    
3. **test** - speech data and transcription for testing the ASR system (Kaldi ASR format)    

*LM/* directory contains 2 text corpus and the language model.

The package contains also 2 *lang/* directories to build whether an ASR system without vowel length contrast modelling whether with vowel length contrast modelling.    
1. **lang_o3g_NoLengthContrast** - contains the lexicon without vowel length tag    
2. **lang_o3g_LengthContrast**  - contains the lexicon with the vowel length tag

#### PUBLICATION ON WOLOF SPEECH & LM DATA
More details on the corpus and how it was collected can be found on the following publication (please cite this bibtex if you use this data).    

  @article{gauthier2016collect,
	Author = {Gauthier, Elodie and Besacier, Laurent and Voisin, Sylvie and Melese, Michael and Elingui, Uriel Pascal},
	Journal = {LREC},
	Title = {Collecting Resources in Sub-Saharan African Languages for Automatic Speech Recognition: a Case Study of Wolof},
	Year = {2016}}


### SCRIPTS
1. In *kaldi-scripts/* you will find the scripts used to train and test models
(PATH variable has to be changed to make it work in your own directory!)
from the existing data and lang directory you can directly start run the sequence : 04\_train\_mono.sh + 04a\_train\_triphone.sh + 04b\_train\_MLLT\_LDA.sh + 04c\_train\_SAT\_FMLLR.sh + 04d\_train\_MMI\_FMMI.sh + 04e\_train\_sgmm.sh + 05\_train\_dnn.sh    
ASR system WITHOUT vowel length contrast has been taking as example in the scripts.    
For more information about the format, please refer to Kaldi website http://kaldi.sourceforge.net/data_prep.html     
2. In *useful_scripts/* you will find some scripts you can use if you desire calculate the CER of your ASR system or calculate the WER/CER on the cleaned data only, etc.    

### WER RESULTS OBTAINED SO FAR 
##### (you should obtain the same on these data if same protocol used)

######           +++ WITHOUT vowel length duration modelling +++

 - dev set
Acoustic models        | WER score *(%)* on **Initial** set  | WER score *(%)* on **Cleaned** set      |
:--------------------- |:-----------------------------------:| :--------------------------------------:|
Monophone *(13 MFCC)*  |                58.3                 |                                         |
Triphone *(13 MFCC)*   |                31.7                 |                 25.2                    |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI |     28.56      |        22.0                    |
DNNs                   |                28.6                 |                                         |
DNNs + sMBR            |                27.21                |                `20.5`                   |

 - test set
Acoustic models        | WER score *(%)* on **Initial** set  | WER score *(%)* on **Cleaned** set       |
:--------------------- |:-----------------------------------:| :---------------------------------------:|
Monophone *(13 MFCC)*  |                64.0                 |                                          |
Triphone *(13 MFCC)*   |                36.0                 |                 27.6                     |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI  |     33.6      |        25.1                     |
DNNs                   |                35.7                 |                                          |
DNNs + sMBR            |                33.6                 |                 `24.9`                   |

###### +++ WITH vowel length duration modelling (only /a/, /e/, /E/, /o/, and /O/) +++

 - dev set
Acoustic models        | WER score *(%)* on **Initial** set  | WER score *(%)* on **Cleaned** set       |
:--------------------- |:-----------------------------------:| :---------------------------------------:|
Monophone *(13 MFCC)*  |                57.7                 |                                          |
Triphone *(13 MFCC)*   |                31.6                 |                                          |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI  |                      |                          |
DNNs                   |                27.8                 |                                          |
DNNs + sMBR            |                26.4                 |                 `20.0`                   |

 - test set
Acoustic models        | WER score *(%)* on **Initial** set  | WER score *(%)* on **Cleaned** set       |
:--------------------- |:-----------------------------------:| :---------------------------------------:|
Monophone *(13 MFCC)*  |                63.0                 |                                          |
Triphone *(13 MFCC)*   |                36.2                 |                                          |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI  |                      |                          |
DNNs                   |                34.0                 |                                          |
DNNs + sMBR            |                32.3                 |                 `24.5`                   |


#### REFERENCES
[1] KALDI: http://kaldi.sourceforge.net/tutorial_running.html
