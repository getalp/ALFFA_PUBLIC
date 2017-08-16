#!/usr/bin/env python3
# -*-coding: utf-8 -*

# --
# - Histograms of durations distribution 
# - Gamma curve fitted on normalized data
# --

import glob, re, argparse, sys
import numpy as np
import scipy as sp
from scipy.stats import gamma as distrib
from scipy import integrate
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

#parsing arguments
parser = argparse.ArgumentParser()
subparsers = parser.add_subparsers(dest="subsampling_method")

parser_full = subparsers.add_parser('full', help="No subsampling")
parser_quartile = subparsers.add_parser('quartile', help="Use Q1 to Q3 quartiles")
parser_cutoff = subparsers.add_parser('cutoff', help="Use a threshold relative to standard deviation")
parser_cutoff.add_argument('cutoff', help="cutoff coefficient (default: %(default)s)", type=float, default=3, nargs="?")
args = parser.parse_args()

if not args.subsampling_method:
	parser.print_help()
	sys.exit(-1)

it = 0
data = {} # dict containing each phoneme and its durations
bins = 10
#output file
log = ""
gamma_plot = ""

if args.subsampling_method == "full":
	log = "durations_stats.log"
	gamma_plot = "GAMMA_plots_NORMED_data.pdf"
elif args.subsampling_method == "quartile":
	log = "quartile_durations_stats.log"
	gamma_plot = "GAMMA_plots_NORMED_quartile_data.pdf"
elif args.subsampling_method == "cutoff":
	log = "sdcutoff_" + str(args.cutoff) + "_durations_stats.log"
	gamma_plot = "GAMMA_plots_NORMED_sdcutoff_"+str(args.cutoff)+"_data.pdf"

for file in sorted (glob.glob("durations/*")):
	name = file.split('/')[-1]
	try:
		phoneme = re.match("distrib-(.*)\.txt", name).group(1)
		durations_list = open(file).read().splitlines()
		durations = sorted([float(x) for x in durations_list])

		size = len(durations)
		m = durations[int(size/2)] # median
		q1 = durations[int(size*(25/100))] # first quartile
		q3 = durations[int(size*(75/100))] # third quartile
		mean_dur = np.mean(durations) # mean duration in milliseconds (= sum(lengths)/nb_occ)
		sd = round(np.std(durations)) # standard deviation

		if args.subsampling_method == "cutoff":
			cutoff = args.cutoff
			durations = sorted([x for x in durations if (x >= (mean_dur - cutoff*sd) and x <= (mean_dur + cutoff*sd))])
		elif args.subsampling_method == "quartile":
			durations = durations[int(size*0.25):int(size*0.75)]

		if args.subsampling_method in ["cutoff", "quartile"]:
			size = len(durations)
			m = durations[int(size/2)] # median
			q1 = durations[int(size*(25/100))] # first quartile
			q3 = durations[int(size*(75/100))] # third quartile
			mean_dur = np.mean(durations) # mean duration in milliseconds (= sum(lengths)/nb_occ)
			sd = round(np.std(durations)) # standard deviation

		data[phoneme] = {
			"duration": np.array(durations),
			"size": size,
			"median": m,
			"Q1": q1, 
			"Q3": q3, 
			"mean": mean_dur,
			"std_deviation": sd
		}
	except AttributeError:
		continue

	it += 1
print("DONE. {} iterations.".format(it))
#endForFile

phonemes = [p for p in data.keys() if len(p) == 1]
for phoneme in phonemes:
	try:
		short_data = data[phoneme]["duration"]
		long_data = data[phoneme + "L"]["duration"]
	except KeyError:
		continue

	## compute the fitting parameters to draw the gamma curve
	params_short = list(distrib.fit(short_data-short_data.min(), f0=10))
	params_long = list(distrib.fit(long_data-long_data.min(), f0=10))

	bin_width = 10
	bins = range(int(min(short_data.min(), long_data.min())-bin_width),int(max(short_data.max(), long_data.max())+bin_width),bin_width)
	x = np.linspace(min(short_data.min(), long_data.min()), max(short_data.max(), long_data.max())+10, 10000)
	colors = ["b", "g"]

	params_short[1] += short_data.min()	
	params_long[1] += long_data.min()	

	## gamma curve fitting the model
	model_short = distrib.pdf(x, *params_short)
	model_long = distrib.pdf(x, *params_long)

	cross_line_indice = np.argwhere(np.diff(np.sign(model_short - model_long)) != 0).reshape(-1) + 0	#point where the curves intersect
	if len(cross_line_indice) > 1:					#if multiple crossover
		a = x[cross_line_indice][-1]
	else:
		a = x[cross_line_indice]					#x value of min interval
	b = max(short_data.max(), long_data.max())+10	#x value of max interval
	area = integrate.quad(lambda x: distrib.pdf(x, *params_long) - distrib.pdf(x, *params_short), a, b)	#area between the two curves

	fig, ax = plt.subplots()
	ax.plot(x, model_short, linewidth=2, color=colors[0], label= "short /{}/".format(phoneme))	#draw the gamma curve for the short model
	ax.plot(x, model_long, linewidth=2, color=colors[1], label= "long /{}/".format(phoneme))	#draw the gamma curve for the long model
	filled_x = np.linspace(a,b) #points in [a,b]
	ax.fill_between(filled_x, distrib.pdf(filled_x, *params_long), distrib.pdf(filled_x, *params_short), color="r", alpha=0.6) #fill the area between the two curves
	ax.hist([short_data, long_data], bins=bins, normed=True, alpha=0.2, color=colors) #draw the histogram
	
	plt.xlabel('duration (in ms)', fontsize=16)
	ax.legend()

	peak1 = x[model_short.argmax()]			# peak of the curve (value of the abscissa)
	y1_short = distrib.pdf(peak1, *params_short)	# ordinate of peak1 on the short curve
	y2_short = distrib.pdf(peak1, *params_long)	# ordinate of the long curve on the same abscissa
	ratio_sl = y1_short/y2_short			# ratio between the two curves on a given abscissa
	
	peak2 = x[model_long.argmax()]			# peak of the curve (value of the abscissa)
	y1_long = distrib.pdf(peak2, *params_short)	# ordinate of peak1 on the short curve)
	y2_long = distrib.pdf(peak2, *params_long)	# ordinate of the long curve on the same abscissa
	ratio_ls = y2_long/y1_long			# ratio between the two curves on a given abscissa

	argmax_delta = peak2 - peak1

	print("---------------------------------")
	print("\t/{}/".format(phoneme))
	print("---------------------------------\n")
	print("Short model of /{}/ ({:,} occurences): ".format(phoneme, data[phoneme]["size"]))
	print("Median of the values is {} ms.".format(data[phoneme]["median"]))
	print("25% of values are inferior or equal to {} ms.".format(data[phoneme]["Q1"]))
	print("75% of values are inferior or equal to {} ms.".format(data[phoneme]["Q3"]))
	print("Average length of the phoneme {:.2f} ms (namely {:.2f} seconds).".format(data[phoneme]["mean"], data[phoneme]["mean"]/1000))
	print("Standard deviation is {} ms.\n".format(data[phoneme]["std_deviation"]))

	print("Peak (x) = {} ms.\n".format(peak1) +
			"Value of y (according to x) for short model (y1) = {}.\n".format(y1_short) +
			"Value of y (according to x) for long model (y2) =  {}.\n".format(y2_short) +
			"Ratio between y1 and y2 = {}.\n".format(ratio_sl)
			)

	print("----------\n")

	print("Long model of /{}/ ({:,} occurences): ".format(phoneme, data[phoneme + "L"]["size"]))
	print("Median of the values is {} ms.".format(data[phoneme + "L"]["median"]))
	print("25% of values are inferior or equal to {} ms.".format(data[phoneme + "L"]["Q1"]))
	print("75% of values are inferior or equal to {} ms.".format(data[phoneme + "L"]["Q3"]))
	print("Average length of the phoneme {:.2f} ms (namely {:.2f} seconds).".format(data[phoneme + "L"]["mean"], data[phoneme + "L"]["mean"]/1000))
	print("Standard deviation is {} ms.\n".format(data[phoneme + "L"]["std_deviation"]))

	print("Peak (x) = {} ms.\n".format(peak2) +
			"Value of y (according to x) for short model (y1) = {}.\n".format(y1_long) +
			"Value of y (according to x) for long model (y2) =  {}.\n".format(y2_long) +
			"Ratio between y2 and y1 = {}.\n".format(ratio_ls)
			)
	print("==========")
	print("Peak's delta is {} ms.".format(argmax_delta))
	print("Area between long model and short model is {}.\n".format(area[0]) +
		"Absolute error of the computed area is {}.\n".format(area[1]) +
		"==========\n"
		)

	## Displays figures
	# plt.show() #DISPLAY FIGURES WITHOUT SAVING THEM
	## Save figures
	#fig.savefig("hist_gamma_"+phoneme+".pdf") #UNCOMMENT IF YOU WANT TO SAVE FIGURES ONE BY ONE
	# plt.close(fig)
	
	#write on file
	with open(log, "a") as outfile:
		outfile.write("---------------------------------\n")
		outfile.write("\t/{}/\n".format(phoneme))
		outfile.write("---------------------------------\n\n")
		outfile.write("Short model of /{}/ ({:,} occurences): \n".format(phoneme, data[phoneme]["size"]))
		outfile.write("Median of the values is {} ms.\n".format(data[phoneme]["median"]))
		outfile.write("25% of values are inferior or equal to {} ms.\n".format(data[phoneme]["Q1"]))
		outfile.write("75% of values are inferior or equal to {} ms.\n".format(data[phoneme]["Q3"]))
		outfile.write("Average length of the phoneme {:.2f} ms (namely {:.2f} seconds).\n".format(data[phoneme]["mean"], data[phoneme]["mean"]/1000))
		outfile.write("Standard deviation is {} ms.".format(data[phoneme]["std_deviation"]))
		outfile.write("\n\n")
		
		outfile.write("Peak (x) = {} ms.\n".format(peak1) +
				"Value of y (according to x) for short model (y1) = {}.\n".format(y1_short) +
				"Value of y (according to x) for long model (y2) =  {}.\n".format(y2_short) +
				"Ratio between y1 and y2 = {}.\n\n".format(ratio_sl)
				)
		outfile.write("----------\n\n")

		outfile.write("Long model of /{}/ ({:,} occurences): \n".format(phoneme, data[phoneme + "L"]["size"]))
		outfile.write("Median of the values is {} ms.\n".format(data[phoneme + "L"]["median"]))
		outfile.write("25% of values are inferior or equal to {} ms.\n".format(data[phoneme + "L"]["Q1"]))
		outfile.write("75% of values are inferior or equal to {} ms.\n".format(data[phoneme + "L"]["Q3"]))
		outfile.write("Average length of the phoneme {:.2f} ms (namely {:.2f} seconds).\n".format(data[phoneme + "L"]["mean"], data[phoneme + "L"]["mean"]/1000))
		outfile.write("Standard deviation is {} ms.".format(data[phoneme + "L"]["std_deviation"]))
		outfile.write("\n\n")
		outfile.write("Peak (x) = {} ms.\n".format(peak2) +
				"Value of y (according to x) for short model (y1) = {}.\n".format(y1_long) +
				"Value of y (according to x) for long model (y2) =  {}.\n".format(y2_long) +
				"Ratio between y2 and y1 = {}.\n\n".format(ratio_ls)
				)
		outfile.write("==========\n")
		outfile.write("Peak's delta is {} ms.\n".format(argmax_delta))
		outfile.write("Area between long model and short model is {}.\n".format(area[0]) +
					"Absolute error of the computed area is {}.\n".format(area[1]) +
					"==========\n"
					)
		outfile.write("\n\n")
	outfile.closed

##save figures on a PDF file
pdf = PdfPages(gamma_plot)
for fig in range(1, plt.figure().number): ## will open an empty extra figure
	pdf.savefig( fig )
pdf.close()
##END
