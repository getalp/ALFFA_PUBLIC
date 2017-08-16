### * HOW TO GET STATS FROM FORCED-ALIGNEMENTS * ###
####                 (Next part)                ####


#### Step 1: convert phoneseg-alignments.ctm to milliseconds
	- input: phoneseg-alignments.ctm
	- output: phoneseg-alignments_ms.ctm

./convert2ms.py

------

#### Step 2: compute durations
	- input: phoneseg-alignments_ms.ctm
	- output: durations/ directory ###### It contains the distributions of the durations

./compute_durations.py

------

## Step 3: compute some stats, plot histogram and draw the pdf of a gamma distribution
	- input: durations/distrib*
	- output: durations_stats.log (name depending on selected option [ full | quartile | cutoff ])

# /!\ plots doesn't work on serveur (except if you have wxtools).... Run it on your personal computer 
./make_stats.py [full | cutoff | quartile]

