#!/usr/bin/perl

#use strict;
use warnings;

$Keystore_base_path = "/var/mqm/ca/larry/20152/";
$CA_Keystore_name = $Keystore_base_path . "AAPMQ_key-CA_2015.kdb";
$CA_Keystore_pass = "MQIsTheKey_2015";
$CA_DN = "CN=WMQCA_2015, OU=WMQ, O=Advance Stores, L=Roanoke, ST=Virginia, C=US";
$CA_Label = "WMQCA_2015";
$CA_Expiredate = 730;
$CA_certificate = "$Keystore_base_path" . "WMQCA_2015.crt";
$QM_Keystore_pass = "TheKeyIsAAP_2015";
$QM_Expiredate = 729;

#############################################################################################################################################################################################
#
# Create QM Keystore, Import CA Public Certificate, Create QM CSR, Sign CSR to QM Certificate, Import QM Certificat
#
#############################################################################################################################################################################################

sub import_QM_Certificate_to_QM_Keystores {
    my ($qmname, $p2, $p3) = @_;
    $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm";

    $cmd = "gsk7cmd -cert -receive -db $QM_Keystore_name -pw $QM_Keystore_pass -file $QM_Cert_File -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not import the QM Certificate: $QM_Cert_File  to the QM Keystore: $QM_Keystore_name.  \n");

    print "\nmqlog----: the QM Certificate $QM_Cert_File has been imported into the QM Keystore: $QM_Keystore_name. \n";
}

sub sign_QM_CSRs {
    my ($qmname, $p2, $p3) = @_;
    $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    $QM_CSR_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_req.arm";
    $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm"; 

    $cmd = "gsk7cmd -cert -sign -file $QM_CSR_File -db $CA_Keystore_name -pw $CA_Keystore_pass -label $CA_Label -target $QM_Cert_File -format ascii -expire $QM_Expiredate";
    (`$cmd` eq "") || die ("\nmqlog----: Could not sign the CSR: $QM_CSR_File using CA Label: $CA_Label in CA Keystore: $CA_Keystore_pass. \n");

    print "\nmqlog----: the QM CSR $QM_CSR_File has been signed and the QM Cert file: $QM_Cert_File has been created. \n";
}

sub create_QM_CSRs {
    my ($qmname, $p2, $p3) = @_;
    $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    $QM_Key_Label = "ibmwebspheremq" . lc($qmname);
    $QM_DN = "CN=IBMWEBSPHEREMQ" . uc ($qmname) . ", OU=WMQ, O=Advance Stores, L=Roanoke, ST=Virginia, C=US";
    $QM_CSR_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_req.arm";

    $cmd = "gsk7cmd -certreq -create -db $QM_Keystore_name -pw $QM_Keystore_pass -label $QM_Key_Label -size 2048 -dn '$QM_DN' -file $QM_CSR_File";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create QM CSR $QM_Key_Label from QM Keystore $QM_Keystore_name\n");

    print "\nmqlog----: the QM CSR $QM_Key_Label has been created from QM Keystore $QM_Keystore_name to $QM_CSR_File\n";
}

sub import_CA_Certificate_to_QM_Keystores {

    my ($qmname, $p2, $p3) = @_;
    $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";

    $cmd = "gsk7cmd -cert -add -db $QM_Keystore_name -pw $QM_Keystore_pass -label $CA_Label -file $CA_certificate -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not the CA Certificate $CA_certificate to QM Keystore $QM_Keystore_name\n");

    print "\nmqlog----: the CA Certificate ($CA_certificate) has been imported into  QM Keystore  $QM_Keystore_name) successfully.\n";
}

sub create_QM_keystore {
    my ($qmname, $p2, $p3) = @_;
    $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    $cmd = "mkdir -p " . $QM_Keystore_path; 

    system($cmd);

    $cmd = "gsk7cmd -keydb -create -db $QM_Keystore_name -pw $QM_Keystore_pass -type cms -stash -expire 7300";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the QM Keystore  $QM_Keystore_name\n");

    print "\nmqlog----: QM Keystore $QM_Keystore_name created\n";

    `gsk7cmd -cert -delete -label 'Thawte Server CA' -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Premium Server CA" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Basic CA" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Freemail CA" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Premium CA" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G3" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G3" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G3" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G2" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G2" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G2" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G2" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Secure Server Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Certification Authority (2048)" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Client Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Client Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Secure Server Certification Authority" -db $QM_Keystore_name -pw $QM_Keystore_pass`;
}

#############################################################################################################################################################################################

#############################################################################################################################################################################################
#
#   Create CA Keystore and Public Certificate
#
#############################################################################################################################################################################################

sub create_CA_public_certificate () {
    $cmd = "gsk7cmd -cert -create -db $CA_Keystore_name -pw $CA_Keystore_pass -size 2048 -dn '$CA_DN' -label $CA_Label -default_cert yes -expire $CA_Expiredate -ca true";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA keypair, $CA_Label\n");

    print "mqlog----: CA Label $CA_Label created in CA Keystore $CA_Keystore_name.\n";

    $cmd = "gsk7cmd -cert -extract -db $CA_Keystore_name -pw $CA_Keystore_pass -label $CA_Label -target $CA_certificate -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not extract the CA certificate. \n");

    print "mqlog----: CA Certificate $CA_certificate has been extracted from CA Keystore $CA_Keystore_name.\n";
}

sub create_CA_keystore () {
    $cmd = "gsk7cmd -keydb -create -db $CA_Keystore_name -pw $CA_Keystore_pass -type cms -stash -expire 7300";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create the CA Keystore\n");

    print "\nmqlog----: CA Keystore $CA_Keystore_name created\n";

    `gsk7cmd -cert -delete -label 'Thawte Server CA' -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Premium Server CA" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Basic CA" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Freemail CA" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Thawte Personal Premium CA" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G3" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G3" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G3" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G3" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority - G2" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority - G2" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority - G2" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 4 Public Primary Certification Authority - G2" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 1 Public Primary Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 2 Public Primary Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "VeriSign Class 3 Public Primary Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Secure Server Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Certification Authority (2048)" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Client Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Client Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
    `gsk7cmd -cert -delete -label "Entrust.net Global Secure Server Certification Authority" -db $CA_Keystore_name -pw $CA_Keystore_pass`;
}

#############################################################################################################################################################################################

sub main () {
    $v1 = 0;
    create_CA_keystore ();
    create_CA_public_certificate ();
    
    print "mqlog----: ", `gsk7cmd -cert -list personal -db $CA_Keystore_name -pw $CA_Keystore_pass`;

    opendir(SNAME, "/var/mqm/ca/dbs") || die ("Unable to open directory");
    while ($QMNAME = readdir(SNAME)) {
        if (((substr $QMNAME, 0, 2) eq "S0") and (length($QMNAME) == 7)) {                   #  and ($v1 < 3)) {
            $qmname = lc($QMNAME);
            $v1 = $v1 + 1;
            create_QM_keystore ($qmname, "b", "c");
            import_CA_Certificate_to_QM_Keystores ($qmname, "b", "c");
            create_QM_CSRs ($qmname, "b", "c");
            sign_QM_CSRs ($qmname, "b", "c");
            import_QM_Certificate_to_QM_Keystores ($qmname, "b", "c");


            $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
            $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";

            print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
        }
    }
    closedir(SNAME);
}


main ();


=head

=cut
