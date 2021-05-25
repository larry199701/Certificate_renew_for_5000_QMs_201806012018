#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                1_mk_Template_keydb_2035_with_both_CAs.pl
#  Usage:               "./1_mk_Template_keydb_2035_with_both_CAs.pl"
#  Description: 
#          1. Create QM Template keystore
#          2. Import_New_Old_CA_Certificate_to_QM_Keystores_Template
#  Date:                2015_08
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

my $Keystore_base_path = "/var/mqm/ca/ca2035/20180529/";
# This CA keystore was created by Eddie
my $CA_Keystore_name = "/var/mqm/ca/ca/wmqca_2035.kdb";
my $CA_Keystore_pass = "MQIsTheKey_2035";

my $CA_Label = "wmqca_2035";
my $CA_Label_2036 = "wmqca_2036";
my $CA_Label_old = "wmqca";
my $CA_certificate_2036 = "/var/mqm/ca/ca/wmqca_2036_cert.arm";
my $CA_certificate_2035 = "/var/mqm/ca/ca/wmqca_2035_cert.arm";
my $CA_certificate_old = "/var/mqm/ca/ca/ca_cert.arm";
#my $CA_certificate_old = "$Keystore_base_path" . "../" . "ca_cert.arm";
my $QM_Keystore_Template_name = $Keystore_base_path . "AAPMQ_Keystore_QM_Template_2035_readonly";
#my $QM_Keystore_Template_name = $Keystore_base_path . "AAPMQ_Keystore_QM_Template_2035";
my $QM_Keystore_pass = "MQAccess";
#my $QM_Keystore_pass = "TheKeyIsAAP";
my $QM_Keystore_Template_Expiredate = 7300;


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
#   Create CA Keystore and QM Keystore Template
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



sub create_QM_keystore_Template () {
    my $cmd = "gsk7cmd -keydb -create -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass -type cms -stash -expire $QM_Keystore_Template_Expiredate";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the QM Keystore Templace $QM_Keystore_Template_name \n");

    print "\nmqlog----: QM Keystore Template $QM_Keystore_Template_name created, removing default keys ... \n";

    `gsk7cmd -cert -delete -label 'Thawte Server CA' -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Premium Server CA" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Basic CA" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Freemail CA" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Premium CA" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G3" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G3" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G3" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G2" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G2" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G2" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G2" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Secure Server Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Certification Authority (2048)" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Client Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Client Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Secure Server Certification Authority" -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;

    print "\nmqlog----: Default keys removed. \n";

}

sub import_New_Old_CA_Certificate_to_QM_Keystores_Template {
    my $cmd = "gsk7cmd -cert -add -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass -label $CA_Label -file $CA_certificate_2035 -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not add the new CA Certificate $CA_certificate_2035 to QM Keystore Template $QM_Keystore_Template_name. \n");

    print "\nmqlog----: the CA Certificate $CA_certificate_2035 has been imported into  QM Keystore Template $QM_Keystore_Template_name successfully.\n";

    $cmd = "gsk7cmd -cert -add -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass -label $CA_Label_2036 -file $CA_certificate_2036 -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not add the old CA Certificate $CA_certificate_old to QM Keystore Template $QM_Keystore_Template_name. \n");

    print "\nmqlog----: the old CA Certificate $CA_certificate_old has been imported into  QM Keystore Template $QM_Keystore_Template_name successfully.\n";
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



sub main () {
    create_QM_keystore_Template ();
    import_New_Old_CA_Certificate_to_QM_Keystores_Template ();
    print "mqlog----: ", `gsk7cmd -cert -list -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
}


main ();


