#!/bin/bash

#reformat for sclite
for dir in *
do
  [ -d $dir ] && pushd $dir
  for file in *txt
  do
    name=`basename $file .txt`
    cat $file | cut -d":" -f1 | sed -e 's/ $/)/g' -e 's/^/(/g' > ids
    cat $file | cut -d":" -f2 | sed 's/^ //g'> trs
    paste trs ids > $name"_reformatted.txt"
  done
  for reformatted_file in *_reformatted.txt
  do
    #char sep
    finame=`basename $reformatted_file .txt` 
    cat $reformatted_file | cut -f1 | sed 's/./& /g' | awk '{print tolower($0)}' > trs_char
    paste trs_char ids > $finame"_char.txt"
  done
  rm ids trs trs_char
  popd
done
