#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                00_mk_Keystore_CA_2036.pl
#  Usage:               "./00_mk_Keystore_CA_2036.pl"
#  Description:         Create CA keystore + public certificate using runmqckm instead of gsk7cmd
#  Date:                2019_01
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

my $KEYMGRCMD = "runmqckm";
my $SIGALG = "SHA256_WITH_RSA";
my $Keystore_CA_path = "/backup/mq/install/ca2036/wmqca_2036/";
my $Keystore_CA_name = "AAPMQ_Keystore_CA_2036.kdb";
my $Keystore_CA_pass = "MQIsTheKey2036";
# Not sure why 7000 or more does not work
my $Keystore_CA_Expiredate = 6500;
my $CA_DN = "CN=wmqca_2036, OU=WMQ, O=Advance Stores, L=Roanoke, ST=Virginia, C=US";
my $CA_Label = "wmqca_2036";
my $CA_Key_Expiredate = 6499;
my $CA_certificate_file = "wmqca_2036.arm";


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub create_CA_keystore () {
    my $cmd = "$KEYMGRCMD -keydb -create -db $Keystore_CA_path"."$Keystore_CA_name -pw $Keystore_CA_pass -type cms -stash -expire $Keystore_CA_Expiredate";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA Keystore\n");
    print "\nmqlog----: CA Keystore $Keystore_CA_name created.  \n";
}

sub create_CA_public_certificate () {

    my $cmd = "$KEYMGRCMD -cert -create -db $Keystore_CA_path"."$Keystore_CA_name -pw $Keystore_CA_pass -size 2048 -dn '$CA_DN' -label $CA_Label -default_cert yes -expire $CA_Key_Expiredate -ca true -sig_alg $SIGALG";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA keypair, $CA_Label\n");
    print "mqlog----: CA Label $CA_Label created in Keystore $Keystore_CA_name. Extracting CA Certificate ... \n";

    $cmd = "$KEYMGRCMD -cert -extract -db $Keystore_CA_path"."$Keystore_CA_name  -pw $Keystore_CA_pass -label $CA_Label -target $Keystore_CA_path$CA_certificate_file -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not extract the CA certificate. \n");
    print "mqlog----: CA Certificate $CA_certificate_file has been extracted from CA Keystore $Keystore_CA_name.\n";
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub main () {
    create_CA_keystore ();
    create_CA_public_certificate();
    print "mqlog----: ", `$KEYMGRCMD -cert -list -db $Keystore_CA_path$Keystore_CA_name -pw $Keystore_CA_pass`;
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

main ();
=head
=cut
