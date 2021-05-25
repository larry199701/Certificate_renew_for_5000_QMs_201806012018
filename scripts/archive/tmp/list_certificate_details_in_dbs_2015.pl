#!/usr/bin/perl

use strict;
use warnings;

my $Keystore_base_path = "/var/mqm/ca/";
my $Keystore_dbs_path = "$Keystore_base_path" . "dbs/";
my $QM_Keystore_pass = "TheKeyIsAAP";


#my $QM_Keystore_pass = "FTEIsTheWayThingsMov";

sub main () {
    my $v1 = 0;
    my $filename = "sssssss1.txt";
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    opendir(SNAME, $Keystore_dbs_path) || die ("Unable to open directory");
    while (my $QMNAME = readdir(SNAME)) {
        if ((substr $QMNAME, 0, 5) ne "AGENT") {
            if ((substr $QMNAME, 0, 2) ne "S0") {
#            if (((substr $QMNAME, 0, 3) eq "S00") and (length($QMNAME) == 7)) {                   
                my $QM_Keystore_name = "$Keystore_dbs_path" . "$QMNAME" . "/" . lc($QMNAME) . ".kdb";
                my $qmname_label = "ibmwebspheremq" . lc($QMNAME);
                print $fh  lc($QMNAME), " ----- ", `gsk7cmd -cert -details -label $qmname_label -db $QM_Keystore_name -pw $QM_Keystore_pass | grep Valid` , "\n"; 
                print $QM_Keystore_name . "\n";
            }
        }
    }
    closedir(SNAME);
    close $fh;
}

main ();




=head
=cut
