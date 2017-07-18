## Wolof Data collected by Elodie Gauthier & Pascal Uriel Elingui 
### Prepared by Elodie Gauthier & Laurent Besacier
#### GETALP LIG, Grenoble, France & Voxygen SAS, Dakar, Sénégal    
     
     
#### OVERVIEW    
The package contains Wolof speech corpus with audio data in the directory *data/*. The data directory contains 6 subdirectories:    
1. **train** - speech data and transcription for training automatic speech recognition system (Kaldi ASR format <sup>1</sup> )    
2. **dev** - speech data and transcription (verified) to evaluate the ASR system (Kaldi ASR format)    
3. **test** - speech data and transcription (verified) for testing the ASR system (Kaldi ASR format)    
4. **dev_unverified** - original speech data and transcription (NOT verified, contains mispronunciations)    
5. **test_unverified** - original speech data and transcription (NOT verified, contains mispronunciations)    
6. **local** - for now, contains the Wolof vocabulary (without length-contrasted units). Once you will ran the *run.sh* script it will contain the *dict/* and *lang/* directories needed to build the ASR system.

*LM/* directory contains 2 text corpus, the language model and its perplexity computed from the *dev* and *test* datasets.    
                  

#### PUBLICATION ON WOLOF SPEECH & LM DATA    
More details on the corpus and how it was collected can be found on the following publication (please cite this bibtex if you use this data).     
  @inproceedings{gauthier2016collecting,    
  	title={Collecting resources in sub-saharan african languages for automatic speech recognition: a case study of wolof},    
  	author={Gauthier, Elodie and Besacier, Laurent and Voisin, Sylvie and Melese, Michael and Elingui, Uriel Pascal},    
  	year={2016},    
  	organization={LREC}}    
                   
### SCRIPTS    
In *kaldi-scripts/* you will find:    
  * **00_init_paths.sh** - it initializes your PATH variable (required to run the Kaldi scripts)    
  * **01_init_symlink.sh** - it creates the symbolic links (required to run the Kaldi scripts)    
  * **02_lexicon.sh** - it creates the dict/ directory used by Kaldi    
  * **03_lm_preparation.sh** - it creates the lang/ directory used by Kaldi    
  * **04_data_prep.sh** - it generates files from the data (essential to built and test the ASR system)
                
                
### WER RESULTS OBTAINED
##### (you should obtain the same on this data if you use the WOLOF-VM with Vagrant)
               
######           +++ WITHOUT vowel length duration modelling +++

 
Acoustic models        | WER score *(%)* on **dev**  | WER score *(%)* on **test**      |
:--------------------- |:-----------------------------------:| :--------------------------------------:|
Triphone *(13 MFCC)*   |                 25.2                |                 27.6                    |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI |     22.0       |        25.1                    |
DNNs + sMBR <sup>2</sup>            |                `20.5`               |                `24.9`                   |
 

###### +++ WITH vowel length duration modelling (only /a/, /e/, /E/, /o/, and /O/) +++

 
Acoustic models        | WER score *(%)* on **dev**  | WER score *(%)* on **test**       |
:--------------------- |:-----------------------------------:| :---------------------------------------:|
Triphone *(13 MFCC)*   |                 25.1                |                  27.9                    |
DNNs + sMBR <sup>2</sup>           |                `20.0`               |                 `24.5`                   |


#### REFERENCES
<sup>1</sup> [KALDI tutorial](http://kaldi-asr.org/doc/tutorial_running.html)    
<sup>2</sup> As it is recommended to run the DNN training using GPU, the process has been commentated at the end of *run.sh* and must be run manually.
