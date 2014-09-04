#!/bin/sh

#use NIST to score (need some beautification!)

# Select the Scoring
STEP1_PrepareRef=0;
STEP2_ScoreMonoTriphone=0;
STEP3_ScoreTriphone=0;
STEP4_ScoreSGMM=1;
STEP5_Scorex=0;
#prepare hyp and ref for sclite 
#ref


if [ $STEP1_PrepareRef -eq 1 ]; then
   echo "make reference text"
   cd data/test
   cat swahili_test.transcription | sed 's/<s> //g' | sed 's/ <\/s>//g'  > swahili_test.ref
   cd ../../
fi


#hyp files
cd exp/system1

if [ $STEP2_ScoreMonoTriphone -eq 1 ]; then
    echo "make hypotheses for MONO, TRI and TRI+DELTA+DELTA TRI+DELTA+DELTA+MLTT+LDA" 
    for type in mono tri1 tri2a tri2b 
    do 
        cd $type/decode_test/scoring
        mkdir sclite_scoring

        for i in 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
        do 
            cat $i.tra | /home/tan/kaldi/swahili/utils/int2sym.pl -f 2- ../../graph/words.txt > tmp_$type-$i
            #perl -p -e's/^.*?\s//g' tmp_$type-$i > tmp_$type-line-$i
            #cat tmp_$type-$i | sed 's/ [a-z]*.*//' > tm:wqp_$type-ids-$i
            perl -p -e's/^(.*)_part(...)(.)\s(.*)/$4 \($3-$1_part$2\)/g' tmp_$type-$i > sclite_scoring/results_$type-$i.hyp 
            #paste tmp_$type-line-$i tmp_$type-ids-$i > tmp_$type-$i_hyp
            #cat tmp_$type-$i_hyp | sed 's/\t/(/g' | sed 's/$/\)/g'  > sclite_scoring/results_$type-$i.hyp  #in scoring folder

            #scoring with sclite
            /home/tan/kaldi-trunk/tools/sctk-2.4.0/src/sclite/sclite -r /home/tan/kaldi/swahili/data/test/swahili_test.ref -h sclite_scoring/results_$type-$i.hyp -i spu_id -o all
        done
        rm tmp_*
        cd ../../../
        echo "$type hyp done"
    done    
fi


if [ $STEP3_ScoreTriphone -eq 1 ]; then

echo "make hypotheses for SAT and SAT+MLLR"
#decode_test_si is SAT applied
#decode_test is SAT+MLLR applied

echo pwd
cd tri3b
for type in decode_test.si decode_test
do
    cd $type/scoring
    mkdir sclite_scoring 
    for i in 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    do
        cat $i.tra | /home/tan/kaldi/swahili/utils/int2sym.pl -f 2- ../../graph/words.txt > tmp_$type-$i
        perl -p -e's/^(.*)_part(...)(.)\s(.*)/$4 \($3-$1_part$2\)/g' tmp_$type-$i > sclite_scoring/results_$type-$i.hyp

        #scoring with sclite
        /home/tan/kaldi-trunk/tools/sctk-2.4.0/src/sclite/sclite -r /home/tan/kaldi/swahili/data/test/swahili_test.ref -h sclite_scoring/results_$type-$i.hyp -i spu_id -o all

    done
    rm tmp_*
    echo "$type hyp done"
    cd ../../../
done

fi

pwd

if [ $STEP4_ScoreSGMM -eq 1 ]; then

    echo "make hypotheses for SGMM" 
    for type in sgmm2_5b2 
    do
        cd $type/decode_test/scoring
        mkdir sclite_scoring

        for i in 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
        do
            cat $i.tra | /home/tan/kaldi/swahili/utils/int2sym.pl -f 2- ../../graph/words.txt > tmp_$type-$i
            perl -p -e's/^(.*)_part(...)(.)\s(.*)/$4 \($3-$1_part$2\)/g' tmp_$type-$i > sclite_scoring/results_$type-$i.hyp

            #scoring with sclite
            /home/tan/kaldi-trunk/tools/sctk-2.4.0/src/sclite/sclite -r /home/tan/kaldi/swahili/data/test/swahili_test.ref -h sclite_scoring/results_$type-$i.hyp -i spu_id -o all
        done
        rm tmp_*
        cd ../../../
        echo "$type hyp done"
    done
fi

