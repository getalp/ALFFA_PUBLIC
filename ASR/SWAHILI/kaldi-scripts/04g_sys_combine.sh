#system combinations: taking best results from system 1, 2 and three

. ./00_init_paths.sh

#local/score_combine.sh data/test lang exp/system1/tri3b/decode_test/  exp/system2/tri3b/decode_test/ exp/system3/tri3b/decode_test/     combine_tri3b_sys1tosy3/decode_test

#local/score_combine.sh --min-lmwt 16 data/test lang exp/system1/tri3b/decode_test/ exp/system2/tri3b/decode_test/ exp/system3/tri3b/decode_test/ combine_tri3b_minlm_16_sys1tosys3/decode_test
