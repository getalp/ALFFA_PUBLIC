#!/usr/bin/env python3
# -*- coding:utf-8 -*-

######                             ######
#######   Convert the duration   ########
###  from seconds to milliseconds   #####
######                             ######

from glob import glob

def convertDuration(ctm_file,ctm_MS_file):
    with open(ctm_MS_file, "a") as ctm_ms:
        for line in open(ctm_file):
            id_loc = line.split(" ")[0] # speaker id
            deb = float(line.split(" ")[2]) # begin time (seconds) of the phone
            deb_ms = str(int(deb*1000)) # converting into milliseconds
            duree = float(line.split(" ")[3]) # duration (seconds) of the phone
            duree_ms = str(int(duree*1000)) # converting into milliseconds
            label = line.split(" ")[4] #label contextuel du phoneme

            ctm_ms.write(id_loc+" 1 "+deb_ms+" "+duree_ms+" "+label+"\n")
    #ctm_ms.closed


#main
ifile = "phoneseg-alignments.ctm"
ofile = "phoneseg-alignments_ms.ctm"
try:
    convertDuration(ifile,ofile)
    print("\nSuccess.\n")
except FileExistsError:
    print("WARNING : File already exists. Please check it.")
