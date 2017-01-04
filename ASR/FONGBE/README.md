## Fongbe Data collected by Fréjus A. A LALEYE    
### Prepared by Elodie Gauthier & Laurent Besacier     
#### Université d’Abomey-Calavi, Bénin & GETALP LIG, Grenoble, France     
     
     
#### OVERVIEW    
The package contains Fongbe speech corpus with audio data in the directory *data/*. The data directory contains 3 subdirectories:   
1. **train** - speech data and transcription for training automatic speech recognition system (Kaldi ASR format [1])    
2. **test** - speech data and transcription (verified) for testing the ASR system (Kaldi ASR format)   
3. **local** - for now, contains the Fongbe vocabulary. Once you will ran the *run.sh* script it will contain the *dict/* and *lang/* directories needed to build the ASR system.    

*LM/* directory contains a text corpus and the language model.      
                  
#### PUBLICATION ON FONGBE SPEECH & LM DATA
More details on the corpus and how it was collected can be found on the following publication (please cite this bibtex if you use this data).   
  @inproceedings{laleye2016FongbeASR,      
        title={First Automatic Fongbe Continuous Speech Recognition System: Development of Acoustic Models and Language Models},     
        author={A. A Laleye, Fréjus and Besacier, Laurent and Ezin, Eugène C. and Motamed, Cina},     
        year={2016},     
        organization={Federated Conference on Computer Science and Information Systems}}    
                   
### SCRIPTS    
In *kaldi-scripts/* you will find:    
  * **00_init_paths.sh** - it initializes your PATH variable (**_NOTE_**: you have to modify this file by yourself)    
  * **01_init_symlink.sh** - it creates the symbolic links required to run the Kaldi scripts
  * **02_lexicon.sh** - it creates the dict/ directory used by Kaldi    
  * **03_lm_preparation.sh** - it creates the lang/ directory used by Kaldi      
                
                
### WER RESULTS OBTAINED
##### (you should obtain the same on this data if you use the FONGBE-VM with Vagrant)
               
Acoustic models                                      | WER score *(%)* on **test**  |
:--------------------------------------------------- |:----------------------------:|
Monophone *(13 MFCC)*                                |             35.34            |
Triphone *(13 MFCC)*                                 |             27.42            |
Triphone (13 MFCC + delta + delta2)                  |             26.75            |
Triphone (39 features) + LDA and MLLT                |             22.25            |
Triphone (39 features) + LDA and MLLT + SAT and FMLLR|             17.77            |
Triphone (39 features) + LDA and MLLT + SGMM         |           `16.57`            |

            
            
#### REFERENCES      
[1] KALDI: http://kaldi.sourceforge.net/tutorial_running.html       
