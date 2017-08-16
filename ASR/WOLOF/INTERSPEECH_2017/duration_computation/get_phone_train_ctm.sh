#!/bin/bash

# This script produces CTM files for phones from a training directory 
# that has alignments present.

# initialize PATH
[ -f 00_init_paths-${HOSTNAME%.imag.fr}.sh ] && . ./00_init_paths-${HOSTNAME%.imag.fr}.sh || exit 1;
#end initialization

cmd=run.pl

echo "$0 $@"

if [ $# -ne 3 ]; then
  echo "Usage: $0 <ali-dir|model-dir> <lang-dir> <output-dir>"
  echo "e.g.:"
  echo "$0 exp/dnn4b_pretrain-dbn_dnn_ali data/lang exp/dnn4b_pretrain-dbn_dnn_ali/forced_aligment"
  echo "Produces phones aligments (CTM format) in: exp/dnn4b_pretrain-dbn_dnn_ali/forced_aligment/phoneseg-alignments.ctm"
  exit 1;
fi

dir=$1
lang=$2 # Note: may be graph directory not lang directory, but has the necessary stuff copied.
output=$3

model=$dir/final.mdl # assume model one level up from decoding dir.

for f in $lang/words.txt $model $dir/ali.1.gz; do
  [ ! -f $f ] && echo "$0: expecting file $f to exist" && exit 1;
done

nj=`cat $dir/num_jobs` || exit 1;

mkdir -p $output $output/log
rm -f $output/phoneseg-alignments.ctm

$cmd JOB=1:$nj $output/log/get_phone_train_ctm.JOB.log \
  set -o pipefail '&&' ali-to-phones --write-lengths=true --ctm-output=true $model "ark:gunzip -c $dir/ali.JOB.gz |" \
  - \| utils/int2sym.pl -f 5 $lang/phones.txt \| \
  gzip -c '>' $output/phoneseg-alignments.JOB.gz

for n in `seq $nj`; do gunzip -c $output/phoneseg-alignments.$n.gz; done > $output/phoneseg-alignments.ctm
rm $output/phoneseg-alignments.*.gz

#for i in {1..14}; do
#  if [[ ! -f "alignment.phoneseg$i" ]]; then
#    ali-to-phones --write-lengths=true --ctm-output=true $model "ark:gunzip -c $dir/ali.JOB.gz |" - | utils/int2sym.pl -f 5 $lang/phones.txt - >> phoneseg-alignments.ctm
#  fi
#done
