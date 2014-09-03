# -*-coding:Utf-8 -*

#*********** Conversion script **********#
#*********        to WAVE       *********# 
########################################## 


# <!> Be sure this script is in the same directory as adc directory but outside <!>

import wave,struct,os
import glob


#### Creation and initialization of the constants
nbCanaux = 1 #mono
echtSize = 2 #sample size
freq =  16000 #sampling rate (Hz)

#### Creation and opening files for writing
path = 'adc'
pathWAV = "wav"

os.mkdir(pathWAV) #WAV directory creation
dirADC = glob.glob(path+'/*')
for i in dirADC:
	loc_ID = i.split('/')[-1]
	os.mkdir('/'.join([pathWAV,loc_ID])) #speaker directory creation
	
	for file in (glob.glob(i+"/*.adc")):
		fichierADC=open(file) #opening current file for reading
		fichierWAV=wave.open(pathWAV+file[3:-4]+".wav","w")	#creation and opening WAV files for writing
		#### copy of data in .wav file
		fichierWAV.setnchannels(nbCanaux)
		fichierWAV.setsampwidth(echtSize)
		fichierWAV.setframerate(freq)
		fichierWAV.setcomptype('NONE','non compresse')
		fichierWAV.writeframesraw(fichierADC.read()) #writing data from .adc file

		#### Close file
		fichierWAV.close()
		fichierADC.close()
	#EOF
#EOF
