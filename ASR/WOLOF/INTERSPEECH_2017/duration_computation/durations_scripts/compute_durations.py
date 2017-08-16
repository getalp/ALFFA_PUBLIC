#!/usr/bin/env python3
# -*-coding: utf-8 -*

##							##
##### COMPUTE DURATIONS TO MAKE STATISTICS ON THEM #######
##							##

import glob, sys, os
from math import sqrt
from os import path, mkdir
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

##output
output_dir = "durations/"
if not path.exists(output_dir):
        mkdir(output_dir)
#fi

#init dict which will retrieve all duration of each phone
durations = {}                                            

with open(output_dir+"forced-alignment-stat.txt", "w") as summary:
	with open("phoneseg-alignments_ms.ctm", "r") as ctm:
		ctm_list = ctm.readlines()
		name = "" 
		for elt in ctm_list:
			curr_name = elt.split()[0]
			if curr_name != name:
				summary.write("\n{}\n".format(curr_name))
				summary.write("-------------------------\n\n")
			duree_ms = float(elt.split()[3]) #duration of the phone in milliseconds in ms
			label = elt.rstrip().split()[4] #e.g.: t_B
			phoneme = label.split('_')[0] #remove word boundary from phoneme
			#retrieval of the phonemes
			if phoneme not in durations:
				durations[phoneme]=[] #add a new entry in the dictionnary
			#fi
			durations[phoneme].append(float(duree_ms))
			summary.write("{}:\t{:.1f} ms\n".format(phoneme, duree_ms)) #write, for each input file, the phone and its corresponding duration in a readable format
			name = curr_name
		#endFor
		summary.write("\n")
	#endFor --processing input file finished
	
	summary.write("------------------------------------------\n")
	summary.write("{:>25s}".format("SUMMARY"))
	summary.write("\n------------------------------------------\n")
	#writing infos in files
	for phoneme, lengths in durations.items():
		with open(output_dir+ "/distrib-" + phoneme + ".txt", "w") as outfile:
			outfile.write("\n".join(["{:.1f}".format(length) for length in lengths])) #write durations one by one
			outfile.write("\n")
		#outfile.closed
		nb_occ=len(lengths) #number of occurrence of the phoneme
		mean_dur=np.mean(lengths) #mean duration of the phoneme in milliseconds #mean_dur=sum(lengths)/nb_occ
		mean_dur_s=mean_dur/1000 #mean duration in seconds
		sd=np.std(lengths) #standard deviation of the phoneme
		summary.write("Phoneme {} appears {} times.\n".format(phoneme,nb_occ))
		summary.write("Average length of the phoneme {} is {:.2f}, namely {:.2f} sec.".format(phoneme,mean_dur,mean_dur_s))
		summary.write("\nStandard deviation of {} is {:.2f}.".format(phoneme,sd))
		summary.write("\n------------------------------------------\n")
		print("------------------------------------------\n")
		print("SUMMARY")
		print("\nPhoneme {} appears {} times.\n".format(phoneme,nb_occ))
		print("Average length of the phoneme {}: {:.2f}, namely {:.2f} sec.".format(phoneme,mean_dur,mean_dur_s))
		print("Standard deviation of {} = {:.2f}\n".format(phoneme,sd))
	#endFor
#summary.closed

###DEBUG
	#phonemes
	phonemes_list=["a","e","i","o","u"]
	phonemes_dict={}

	for phoneme in phonemes_list:
		phonemes_dict[phoneme]={} #phonemes_dict = {'i': {}, 'a': {}, 'e': {}, 'o': {}, 'u': {}}

	#phones
	'''
	phones = ["a","e", "E", "@", "i", "o", "O", "u", "aL","eL", "EL", "iL", "oL", "OL", "uL"]
	short_phones = ["a","e", "E", "@", "i", "o", "O", "u"]
	long_phones = ["aL","eL", "EL", "iL", "oL", "OL", "uL"]
	'''
	a_phonesList = ["a","aL"]
	e_phonesList = ["e","eL", "E", "EL", "@"]
	i_phonesList = ["i","iL"]
	o_phonesList = ["o","oL","O", "OL"]
	u_phonesList = ["u","uL"]

	error_count = 0 #counter of the number of phones without duration
	error_wordlist = [] #list of the phones without duration
	for phone in a_phonesList:
		try:
			phonemes_dict["a"][phone]=durations[phone] #phonemes_dict = {'i': {}, 'a': {'aL': [115,100,56,180], 'a': [36,21,95,48]}, 'e': {}, 'o': {}, 'u': {}}
		except KeyError:
			error_count = error_count+1
			error_wordlist.append(phone)
			continue
	for phone in e_phonesList:
		try:
			phonemes_dict["e"][phone]=durations[phone]
		except KeyError:
			error_count = error_count+1
			error_wordlist.append(phone)
			continue
	for phone in i_phonesList:
		try:
			phonemes_dict["i"][phone]=durations[phone]
		except KeyError:
			error_count = error_count+1
			error_wordlist.append(phone)
			continue
	for phone in o_phonesList:
		try:
			phonemes_dict["o"][phone]=durations[phone]
		except KeyError:
			error_count = error_count+1
			error_wordlist.append(phone)
			continue
	for phone in u_phonesList:
		try:
			phonemes_dict["u"][phone]=durations[phone]
		except KeyError:
			error_count = error_count+1
			error_wordlist.append(phone)
			continue
	#
	print(" ** WARNING ** \t {0} phones without duration: {1}".format(error_count,error_wordlist))

