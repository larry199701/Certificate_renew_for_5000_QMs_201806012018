#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                create_CAKeystore_QMTemplateKeystore_2035.pl
#  Usage:               "./create_CAKeystore_QMTemplateKeystore_2035.pl"
#  Description:         Create CA keystore and QM Template keystore
#  Date:                2015_08
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

my $Keystore_base_path = "/var/mqm/ca/mq_scripts_ca_keystores_2015/201591/";
my $CA_Keystore_name = $Keystore_base_path . "AAPMQ_Keystore_CA_2035";
my $CA_Keystore_pass = "MQIsTheKey_2035";
my $CA_Keystore_Expiredate = 7300;
my $CA_DN = "CN=wmqca_2035, OU=WMQ, O=Advance Stores, L=Roanoke, ST=Virginia, C=US";
my $CA_Label = "wmqca_2035";
my $CA_Label_old = "wmqca";
my $CA_Key_Expiredate = 7299;
my $CA_certificate = "$Keystore_base_path" . "wmqca_2035.crt";
my $CA_certificate_old = "$Keystore_base_path" . "../" . "ca_cert.arm";
my $QM_Keystore_Template_name = $Keystore_base_path . "AAPMQ_Keystore_QM_Template_2035";
my $QM_Keystore_pass = "TheKeyIsAAP";
my $QM_Keystore_Template_Expiredate = 7300;
my $QM_Cert_Expiredate = 1460;


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
#   Create CA Keystore and QM Keystore Template
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub create_CA_keystore () {
    my $cmd = "gsk7cmd -keydb -create -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass -type cms -stash -expire $CA_Keystore_Expiredate";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA Keystore\n");

    print "\nmqlog----: CA Keystore $CA_Keystore_name created, removing default keys ... \n";

    `gsk7cmd -cert -delete -label 'Thawte Server CA' -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Premium Server CA" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Basic CA" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Freemail CA" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Premium CA" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G3" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G3" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G3" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G2" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G2" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G2" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G2" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Secure Server Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Certification Authority (2048)" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Client Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Client Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Secure Server Certification Authority" -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;

    print "\nmqlog----: Default keys removed. \n";
}

sub create_CA_public_certificate () {
    my $cmd = "gsk7cmd -cert -create -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass -size 2048 -dn '$CA_DN' -label $CA_Label -default_cert yes -expire $CA_Key_Expiredate -ca true";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA keypair, $CA_Label\n");

    print "mqlog----: CA Label $CA_Label created in CA Keystore $CA_Keystore_name. Extracting CA Certificate ... \n";

    $cmd = "gsk7cmd -cert -extract -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass -label $CA_Label -target $CA_certificate -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not extract the CA certificate. \n");

    print "mqlog----: CA Certificate $CA_certificate has been extracted from CA Keystore $CA_Keystore_name.\n";
}

sub import_New_Old_CA_Certificate_to_QM_Keystores_Template {
    my $cmd = "gsk7cmd -cert -add -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass -label $CA_Label -file $CA_certificate -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not the CA Certificate $CA_certificate to QM Keystore Template $QM_Keystore_Template_name. \n");

    print "\nmqlog----: the CA Certificate $CA_certificate has been imported into  QM Keystore Template $QM_Keystore_Template_name successfully.\n";

    $cmd = "gsk7cmd -cert -add -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass -label $CA_Label_old -file $CA_certificate_old -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not the CA Certificate $CA_certificate to QM Keystore Template $QM_Keystore_Template_name. \n");

    print "\nmqlog----: the old CA Certificate $CA_certificate_old has been imported into  QM Keystore Template $QM_Keystore_Template_name successfully.\n";
}

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

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



sub main () {
    create_CA_keystore ();
    create_CA_public_certificate ();
    create_QM_keystore_Template ();
    import_New_Old_CA_Certificate_to_QM_Keystores_Template ();
    print "mqlog----: ", `gsk7cmd -cert -list -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass`;
    print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_Template_name.kdb -pw $QM_Keystore_pass`;
}


main ();


