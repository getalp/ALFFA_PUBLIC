#!/bin/sh

###  Generate reference files ###
## for CER scoring with sclite ##


# <!> Assuming your dev set is in data/ <!>

#prep ref for sclite (in order to calculate the CER)
cat data/dev/dev.ref | awk 'BEGIN {FS="("} {print $1}' | sed 's/./& /g' > toto
cat data/dev/dev.ref | awk 'BEGIN {FS="("} {print "("$2}' > tata
paste toto tata > data/dev/dev-char.ref
sed -i 's/WOL_//g' data/dev/dev-char.ref
rm toto tata

##same process for cleaned data
cat data/dev/dev-checked_and_good.ref | awk 'BEGIN {FS="("} {print $1}' | sed 's/./& /g' > titi
cat data/dev/dev-checked_and_good.ref | awk 'BEGIN {FS="("} {print "("$2}' > tutu
paste titi tutu > data/dev/dev-checked_and_good-char.ref
sed -i 's/WOL_//g' data/dev/dev-checked_and_good-char.ref
rm titi tutu
