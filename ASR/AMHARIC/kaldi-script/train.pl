# To run : perl -w deplace.pl input > output
use strict;
use utf8 ;

open (IN,$ARGV[0]);

while( my $ligne =<IN>){
        $ligne=~s/<s>|<\/s>//gi;
        $ligne=~s/^(.+)(\(tr_\d+_tr\d+\))$/$2$1/gi;
        $ligne=~s/\((tr_\d+_tr\d+)\)/$1/gi;
        print $ligne;

}
close (IN);
