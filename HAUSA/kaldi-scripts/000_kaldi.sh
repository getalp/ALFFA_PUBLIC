#!/bin/sh

. 00_init_paths.sh

## all-in-one 
#script will run all scripts one by one

#### DON'T FORGET TO RUN 00_init_paths.sh BEFORE START THIS  ####	

echo "do mono step"
./04_train_mono.sh
echo "mono done"

echo "do triphones step"
./04a_train_triphone.sh
echo "triphones done"

echo "do MLLT+LDA step"
./04b_train_MLLT_LDA.sh
echo "MLLT+LDA step done"

echo "do SAT+FMMLR step"
./04c_train_SAT_FMLLR.sh
echo "SAT+FMMLR done"

echo "do MMI+FMMI step"
./04d_train_MMI_FMMI.sh
echo "MMI+FMMI done"

echo "do SGMM and SGMM+MMI steps"
./04e_train_sgmm.sh
echo "SGMM done"

