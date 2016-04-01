#!/bin/sh

###  Generate reference files ###
## for CER scoring with sclite ##

# <!> Assuming your test set is in data/ <!>

#prep ref for sclite (for CER scoring)
cat data/test/test.ref | awk 'BEGIN {FS="("} {print $1}' | sed 's/./& /g' > toto
cat data/test/test.ref | awk 'BEGIN {FS="("} {print "("$2}' > tata
paste toto tata > data/test/test-char.ref
sed -i 's/WOL_//g' data/test/test-char.ref
rm toto tata

##same process for cleaned data
cat data/test/test-checked_and_good.ref | awk 'BEGIN {FS="("} {print $1}' | sed 's/./& /g' > titi
cat data/test/test-checked_and_good.ref | awk 'BEGIN {FS="("} {print "("$2}' > tutu
paste titi tutu > data/test/test-checked_and_good-char.ref
sed -i 's/WOL_//g' data/test/test-checked_and_good-char.ref
rm titi tutu
