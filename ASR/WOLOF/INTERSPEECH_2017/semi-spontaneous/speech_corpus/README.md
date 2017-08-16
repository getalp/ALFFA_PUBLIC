This directory contains recordings made by S.Voisin during a fieldwork in Senegal in January 2016.
Recordings were long PCM files (44.1kHz, 16bits, dual channel). 
For the decoding purpose, audio files have been splitted into small files, using WavAutoSegmentor (see https://github.com/FredericAMAN/WavAutoSegmentor).
Then, files were converted to 16kHz, mono, using SoX tool.
Finally, noise cancelling algorithm has been applied when necessary, using Audacity.

scoring/ contains WER score computed with sclite for each speakers of Faana-Faana (FF) and Wolof (WW).

**Wolof read speech corpus** used for experimentations can be found in <https://github.com/besacier/ALFFA_PUBLIC/tree/master/ASR/WOLOF/data/dev>.
