#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                01_mk_Keystore_Template_2036_with_both_CAs.pl
#  Usage:               "./01_mk_Keystore_Template_2036_with_both_CAs.pl"
#  Description: 
#          1. create_Keystore_Template ()
#          2. add_Old_CA_Certificate_to_Keystore_Template ()
#          3. add_New_CA_Certificate_to_Keystore_Template ()
#  Date:                2019_01
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

my $KEYMGRCMD = "runmqckm";

my $Keystore_Template_path = "/backup/mq/install/ca2036/wmqca_2036/";
my $Keystore_Template_name = "AAPMQ_Keystore_Template_2036.kdb";
my $Keystore_Template_pass = "TheKeyIsAAP";
my $Keystore_Template_expire = 6400;
my $CA_Label_old = "wmqca";
my $CA_Label_2036 = "wmqca_2036";
my $CA_certificate_old = "ca_cert.arm";
my $CA_certificate_2036 = "wmqca_2036.arm";


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
#   Create QM Keystore Template
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub create_Keystore_Template () {
    my $cmd = "$KEYMGRCMD -keydb -create -db $Keystore_Template_path"."$Keystore_Template_name -pw $Keystore_Template_pass -type cms -stash -expire $Keystore_Template_expire";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the Keystore Template $Keystore_Template_name! \n");
    print "\nmqlog----: Keystore Template $Keystore_Template_name created! \n";
}

sub add_Old_CA_Certificate_to_Keystore_Template {
    my $cmd = "$KEYMGRCMD -cert -add -db $Keystore_Template_path"."$Keystore_Template_name -pw $Keystore_Template_pass -label $CA_Label_old -file $Keystore_Template_path"."$CA_certificate_old -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not add the old CA Certificate $CA_certificate_old to Keystore Template $Keystore_Template_name. \n");
    print "\nmqlog----: the old CA Certificate $CA_certificate_old has been added into  Keystore Template $Keystore_Template_name successfully.\n";
}

sub add_New_CA_Certificate_to_Keystore_Template {
    my $cmd = "$KEYMGRCMD -cert -add -db $Keystore_Template_path"."$Keystore_Template_name -pw $Keystore_Template_pass -label $CA_Label_2036 -file $Keystore_Template_path"."$CA_certificate_2036 -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not add the new CA Certificate $CA_certificate_2036 to QM Keystore Template $Keystore_Template_name. \n");
    print "\nmqlog----: the CA Certificate $CA_certificate_2036 has been added into  Keystore Template $Keystore_Template_name successfully.\n";
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub main () {
    create_Keystore_Template ();
    add_Old_CA_Certificate_to_Keystore_Template ();
    add_New_CA_Certificate_to_Keystore_Template ();
    print "mqlog----: ", `$KEYMGRCMD -cert -list -db $Keystore_Template_path$Keystore_Template_name -pw $Keystore_Template_pass`;
}

main ();
=head
=cut

