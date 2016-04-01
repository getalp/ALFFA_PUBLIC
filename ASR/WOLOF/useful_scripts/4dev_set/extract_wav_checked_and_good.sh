#!/bin/bash

# ********************************************************************** #
# *** Copy the WAVE files corresponding to the transcripts validated *** #
#            by the Wolof expert (using Lig-Aikuma mobile app)           # 
#                         in a proper directory                          # 
# ********************************************************************** #

pushd data/dev
  mkdir -p wav-checked_and_good
  for ID in $(cat dev-checked_and_good.ref | cut -d"(" -f2- | cut -d")" -f1)
  do
    file=$(find -name *${ID}*); 
    cp $file wav-checked_and_good
  done
popd
