use strict;
use utf8 ;

open (IN,$ARGV[0]);

while( my $ligne =<IN>){
        $ligne=~s/<s>|<\/s>//gi;
        $ligne=~s/^(.+)(\(\d+_d\d+\))$/$2$1/gi;
        $ligne=~s/\((\d+_d\d+)\)/$1/gi;
        print $ligne;

}
close (IN);

