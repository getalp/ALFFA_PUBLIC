### WOLOF TEXT CORPUS AND LANGUAGE MODEL          
          
Directory: LM/          
3 Files: combineV1-web-W0.9-3gram.arpa, WOL.txt, wo_SN-web_crawled.txt          
          
####combineV1-web-W0.9-3gram.arpa          
Language model created using [SRILM](http://www.speech.sri.com/projects/srilm/) by interpolation of two language models: the one generated with WOL.txt (weight 0.9) and the one generated with wo_SN-web_crawled.txt (weight 0.1)          
          
####WOL.txt          
text data retrieved from corpus collected for the purpose of [1], post-processed by converting text into TXT format and lower case and by cleaning them from non-wolof data (like section numbering, numbered list, french notes, etc.) and punctuation.          
Total of words: 106,206 ; Vocabulary size = 11,065          
          
####wo_SN-web_crawled.txt          
text data crawled on the Web (Universal Declaration of Human Rights, Silo's Message, The Bible, Wikipedia Database).          
Total of words: 641,483 ; Vocabulary size: 29,128          
          
#### REFERENCES          
[1] Nouguier Voisin, S. (2002). *Relations entre fonctions syntaxiques et fonctions semantiques en wolof.* Ph.D. thesis, Lyon 2.          
