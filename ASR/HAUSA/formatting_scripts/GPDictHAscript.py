# -*-coding:Utf-8 -*


#######################################################
########### Pronunciation dictionary formatting #######
#################### Without any tag ##################
#######################################################


# <!> Be sure this script is in the same directory as the pronunciation dictionary GlobalPhone Hausa <!>


#opening file for writing
OUT=open("lexicon.txt","w")

#reading pronunciation dictionary GlobalPhone Hausa
for line in open("Hausa-GPDict.txt"):
	a, b=line.split(" {{")
	a = a[1:-1]
	OUT.write(a.lower()+"\t") #convert and write lexeme into lower case
	c=""
	for e in b.split("_")[1:]:
		c+=e.split(" ")[0]+" "
	OUT.write(c[:-1])
	OUT.write("\n")
	#EOF
#EOF

#Close file
OUT.close()
