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
  * **02_dict_script.sh** - it creates the dict/ directory used by Kaldi    
  * **03_lm_preparation.sh** - it creates the lang/ directory used by Kaldi      
                
                
### WER RESULTS OBTAINED
##### (you should obtain the same on this data if same protocol used)
               
Acoustic models                                      | WER score *(%)* on **test**  |
:--------------------------------------------------- |:----------------------------:|
Monophone *(13 MFCC)*                                |             37.16            |
Triphone *(13 MFCC)*                                 |             27.88            |
Triphone (13 MFCC + delta + delta2)                  |             27.65            |
Triphone (39 features) + LDA and MLLT                |             23.55            |
Triphone (39 features) + LDA and MLLT + SAT and FMLLR|             18.47            |
Triphone (39 features) + LDA and MLLT + SGMM         |           `17.03`            |
Triphone *(39 features)* + LDA and MLLT + SGMM + MMI |             18.09            |      
            
            
#### REFERENCES      
[1] KALDI: http://kaldi.sourceforge.net/tutorial_running.html       
