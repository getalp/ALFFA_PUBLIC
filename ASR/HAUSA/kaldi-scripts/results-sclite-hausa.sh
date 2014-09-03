#!/bin/sh

#use NIST to score (need some beautification!)

###step 1 : prepare hyp and ref for sclite 

#ref
echo "make reference text"
cd data/dev
cat trsDev.txt | awk 'BEGIN {FS="\t"} {print tolower($1) $2}' | sed 's/<s> //g' | sed 's/ <\/s>//g' | sed 's/ha/HA/g' > hausa_dev.ref 
cd ../..

#hyp files
cd /home/gauthier/kaldi/exp/system1
echo "make hypotheses for MONO, TRI and TRI+DELTA+DELTA TRI+DELTA+DELTA+MLTT+LDA" 
for type in mono tri1 tri2a tri2b
do
    cd $type/decode/scoring

    for i in 9 10 11 12 13 14 15 16 17 18 19 20
    do
        cat $i.tra | ../../../../../utils/int2sym.pl -f 2- ../../graph/words.txt > tmp_$type-$i
        cat tmp_$type-$i | sed 's/HA[0-9]*_[0-9]* //g' > tmp_$type-line-$i
        cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tmp_$type-ids-$i
        paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
        cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g' > results_$type-$i.hyp  #in scoring folder
    done
    rm tmp_*
    echo "$type hyp done"
    cd ../../../
done

#run sclite for calculating 
#mono, tri, tri+d+d, tri+d+d+MLLT+LDults_combine-
for type in mono tri1 tri2a tri2b
do
    cd $type/decode/scoring
    mkdir sclite_results
    for i in 9 10 11 12 13 14 15 16 17 18 19 20
    do
        mv results_$type-$i.hyp sclite_results/
        ../../../../../sclite -r ../../../../../data/dev/hausa_dev.ref -h sclite_results/results_$type-$i.hyp -i spu_id -o all
    done
    cd ../../../
done

echo "make hypotheses for SAT and SAT+MLLR"
#decode_test_si is SAT applied
#decode_test is SAT+MLLR applied

cd /home/gauthier/kaldi/exp/system1/tri3b
for type in decode decode.si
do
    cd $type/scoring
    mkdir sclite_results/
    for i in 9 10 11 12 13 14 15 16 17 18 19 20
    do
        cat $i.tra | ../../../../../utils/int2sym.pl -f 2- ../../graph/words.txt > tmp_$type-$i
        cat tmp_$type-$i | sed 's/HA[0-9]*_[0-9]* //g' > tmp_$type-line-$i
        cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tmp_$type-ids-$i
        paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
        cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g' > sclite_results/results_$type-$i.hyp  #in scoring folder
        #run sclite for calculating
        ../../../../../sclite -r ../../../../../data/dev/hausa_dev.ref -h sclite_results/results_$type-$i.hyp -i spu_id -o all
    done
    rm tmp_*
    echo "$type hyp and results done"
    cd ../../
done

#hyp files for tri+fmmi 
cd /home/gauthier/kaldi/exp/system1/
for dir in tri3b_fmmi_a tri3b_fmmi_indirect
do
   for type in decode_it3 decode_it4 decode_it5 decode_it6 decode_it7 decode_it8
   do
      cd $dir/$type/scoring
      mkdir sclite_results/
      for i in 9 10 11 12 13 14 15 16 17 18 19 20
      do
          cat $i.tra | ../../../../../utils/int2sym.pl -f 2- /home/gauthier/kaldi/exp/system1/mono/graph/words.txt > tmp_$type-$i
          cat tmp_$type-$i | sed 's/HA[0-9]*_[0-9]* //g' > tmp_$type-line-$i
          cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tmp_$type-ids-$i
          paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
          cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g' > sclite_results/results_$type-$i.hyp  #in scoring folder
          #run sclite for calculating
          ../../../../../sclite -r ../../../../../data/dev/hausa_dev.ref -h sclite_results/results_$type-$i.hyp -i spu_id -o all
      done
    rm tmp_*
    echo "$type hyp and results done"
    cd ../../../
   done
done

#hyp files for tri+mmi and sgmm
cd /home/gauthier/kaldi/exp/system1
echo "make hypotheses for TRI+MMI SGMM" 
for type in tri3b_mmi_b0.1 sgmm2_5b2
do
    cd $type/decode/scoring
    mkdir sclite_results/
    for i in 9 10 11 12 13 14 15 16 17 18 19 20
    do
        cat $i.tra | ../../../../../utils/int2sym.pl -f 2- /home/gauthier/kaldi/exp/system1/sgmm2_5b2/graph/words.txt > tmp_$type-$i
        cat tmp_$type-$i | sed 's/HA[0-9]*_[0-9]* //g' > tmp_$type-line-$i
        cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tmp_$type-ids-$i
        paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
        cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g' > sclite_results/results_$type-$i.hyp  #in scoring folder
        #run sclite for calculating
        ../../../../../sclite -r ../../../../../data/dev/hausa_dev.ref -h sclite_results/results_$type-$i.hyp -i spu_id -o all 
    done
    rm tmp_*
    echo "$type hyp and results done"
    cd ../../../
done

#hyp files for sgmm+mmi
cd /home/gauthier/kaldi/exp/system1/sgmm2_5b2_mmi_b0.1
echo "make hypotheses for SGMM+MMI"
for type in decode_it1 decode_it2 decode_it3 decode_it3.mbr decode_it4
do
    cd $type/scoring
    mkdir sclite_results/
    for i in 9 10 11 12 13 14 15 16 17 18 19 20
    do
        cat $i.tra | ../../../../../utils/int2sym.pl -f 2- /home/gauthier/kaldi/exp/system1/sgmm2_5b2/graph/words.txt > tmp_$type-$i
        cat tmp_$type-$i | sed 's/HA[0-9]*_[0-9]* //g' > tmp_$type-line-$i
        cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tmp_$type-ids-$i
        paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
        cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g' > sclite_results/results_$type-$i.hyp  #in scoring folder
        #run sclite for calculating
        ../../../../../sclite -r ../../../../../data/dev/hausa_dev.ref -h sclite_results/results_$type-$i.hyp -i spu_id -o all
    done
    rm tmp_*
    echo "$type hyp and results done"
    cd ../../
done


###step 2 : compile sys results
echo "check outputs in scoring/sclite_results"

cd /home/gauthier/kaldi/exp/system1/
echo "do compile sys results"
for type in mono tri1 tri2a tri2b
do
    cat /home/gauthier/kaldi/exp/system1/$type/decode/scoring/sclite_results/results_$type-*.hyp.sys > /home/gauthier/kaldi/exp/system1/$type/decode/scoring/sclite_results/results_$type-all.hyp.sys
done

#tri3b; SAT and SAT+MLLR
cd /home/gauthier/kaldi/exp/system1/tri3b

for type in decode.si decode
do
    cat /home/gauthier/kaldi/exp/system1/tri3b/$type/scoring/sclite_results/results_$type-*.hyp.sys > /home/gauthier/kaldi/exp/system1/tri3b/$type/scoring/sclite_results/results_$type-all.hyp.sys
    cd ../..
done
echo "compile sys results done"

#tri3b_fmmi_a tri3b_fmmi_indirect
echo "compile sys results done"
cd /home/gauthier/kaldi/exp/system1/

for dir in tri3b_fmmi_a tri3b_fmmi_indirect
do
        for type in decode_it3 decode_it4 decode_it5 decode_it6 decode_it7 decode_it8
        do
                cat /home/gauthier/kaldi/exp/system1/$dir/$type/scoring/sclite_results/results_$type-*.hyp.sys > /home/gauthier/kaldi/exp/system1/$dir/$type/scoring/sclite_results/results_$type-all.hyp.sys
        done
cd ../../
done
echo "compile sys results done"

#tri+mmi and sgmm
for type in tri3b_mmi_b0.1 sgmm2_5b2
do
    cat /home/gauthier/kaldi/exp/system1/$type/decode/scoring/sclite_results/results_$type-*.hyp.sys > /home/gauthier/kaldi/exp/system1/$type/decode/scoring/sclite_results/results_$type-all.hyp.sys
done

#sgmm+mmi
cd /home/gauthier/kaldi/exp/system1/sgmm2_5b2_mmi_b0.1

for type in decode_it1 decode_it2 decode_it3 decode_it3.mbr decode_it4
do
    cat /home/gauthier/kaldi/exp/system1/sgmm2_5b2_mmi_b0.1/$type/scoring/sclite_results/results_$type-*.hyp.sys > /home/gauthier/kaldi/exp/system1/sgmm2_5b2_mmi_b0.1/$type/scoring/sclite_results/results_$type-all.hyp.sys
    cd ../..
done
