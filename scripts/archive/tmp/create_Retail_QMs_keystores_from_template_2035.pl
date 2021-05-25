#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                create_keystores_from_template.pl
#  Usage:               "./create_keystores_from_template.pl"
#  Description:         Create all CA, corp, retail qmgr keystores
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
# Create QM Keystore from QM Keystore Template, Import CA Public Certificate, Create QM CSR, Sign CSR to QM Certificate, Import QM Certificat
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub copy_QM_Keystore_from_QM_Keystore_Template {
    my ($qmname, $env, $p3) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $cmd = "mkdir -p " . $QM_Keystore_path;
    system($cmd);

    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname);
    $cmd = "cp $QM_Keystore_Template_name.crl $QM_Keystore_name.crl";
    system($cmd);
    $cmd = "cp $QM_Keystore_Template_name.kdb $QM_Keystore_name.kdb";
    system($cmd);
    $cmd = "cp $QM_Keystore_Template_name.rdb $QM_Keystore_name.rdb";
    system($cmd);
    $cmd = "cp $QM_Keystore_Template_name.sth $QM_Keystore_name.sth";
    system($cmd);

    print "\nmqlog----: $QM_Keystore_path has been copied. \n";
}

sub create_QM_CSRs {
    my ($qmname, $env, $p3) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    my $QM_Key_Label = "ibmwebspheremq" . lc($qmname);
    my $QM_DN = "CN=" . lc ($qmname) . ",OU=WMQ,O=Advance Auto Parts,C=US";
    my $QM_CSR_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_req.arm";

    my $cmd = "gsk7cmd -certreq -create -db $QM_Keystore_name -pw $QM_Keystore_pass -label $QM_Key_Label -size 2048 -dn '$QM_DN' -file $QM_CSR_File";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create QM CSR $QM_Key_Label from QM Keystore $QM_Keystore_name\n");

    print "\nmqlog----: the QM CSR $QM_Key_Label has been created from QM Keystore $QM_Keystore_name to $QM_CSR_File\n";
}

sub sign_QM_CSRs {
    my ($qmname, $env, $p3) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_CSR_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_req.arm";
    my $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm";

    my $cmd = "gsk7cmd -cert -sign -file $QM_CSR_File -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass -label $CA_Label -target $QM_Cert_File -format ascii -expire $QM_Cert_Expiredate";

    print $cmd . "\n";
    (`$cmd` eq "") || die ("\nmqlog----: Could not sign the CSR: $QM_CSR_File using CA Label: $CA_Label in CA Keystore: $CA_Keystore_name.kdb. \n");

    print "\nmqlog----: the QM CSR $QM_CSR_File has been signed and the QM Cert file: $QM_Cert_File has been created. \n";
}

sub import_QM_Certificate_to_QM_Keystores {
    my ($qmname, $env, $p3) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    my $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm";

    my $cmd = "gsk7cmd -cert -receive -db $QM_Keystore_name -pw $QM_Keystore_pass -file $QM_Cert_File -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not import the QM Certificate: $QM_Cert_File  to the QM Keystore: $QM_Keystore_name.  \n");

    print "\nmqlog----: the QM Certificate $QM_Cert_File has been imported into the QM Keystore: $QM_Keystore_name. \n";
}

sub remove_qm_csr_cert_file {
    my ($env, $p2, $p3) = @_;
    my $cmd = "rm $Keystore_base_path/dbs_" . "$env" . "/*/*.arm";
    print $cmd;
#    system($cmd);
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub create_retail_store_MQ_server_keystores_Prd () {
    opendir(SNAME, "/var/mqm/ca/mq_scripts_ca_keystores_2015/expiring_certs/dbs_expired_2015") || die ("Unable to open directory");
    while (my $QMNAME = readdir(SNAME)) {
        if (((substr $QMNAME, 0, 2) eq "S0") and (length($QMNAME) == 7)) { 
            if ((substr $QMNAME, 0, 3) ne "S00") { 
                my $qmname = lc($QMNAME);
                copy_QM_Keystore_from_QM_Keystore_Template ($qmname, "Prd", "c");
                create_QM_CSRs ($qmname, "Prd", "c");
                sign_QM_CSRs ($qmname, "Prd", "c");
                import_QM_Certificate_to_QM_Keystores ($qmname, "Prd", "c");
                remove_qm_csr_cert_file ("Prd", "b", "c");

                my $QM_Keystore_path = "$Keystore_base_path" . "dbs_Prd/" . uc($qmname) . "/";
                my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
                print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
            }
        }
    }
    closedir(SNAME);
}

sub create_retail_store_MQ_server_keystores_S00_QADev () {
    opendir(SNAME, "/var/mqm/ca/dbs") || die ("Unable to open directory");
    while (my $QMNAME = readdir(SNAME)) {
        if (((substr $QMNAME, 0, 3) eq "S00") and (length($QMNAME) == 7)) {
                my $qmname = lc($QMNAME);
                copy_QM_Keystore_from_QM_Keystore_Template ($qmname, "QADev", "c");
                create_QM_CSRs ($qmname, "QADev", "c");
                sign_QM_CSRs ($qmname, "QADev", "c");
                import_QM_Certificate_to_QM_Keystores ($qmname, "QADev", "c");
                remove_qm_csr_cert_file ("QADev", "b", "c");

                my $QM_Keystore_path = "$Keystore_base_path" . "dbs_QADev/" . uc($qmname) . "/";
                my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
                print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
        }
    }
    closedir(SNAME);
}

sub create_a_MQ_server_keystore () {
#    my $qmname = "larrydr01";
#    my $qmname = "larrydr02";
    my $qmname = "larrys09999a";

    copy_QM_Keystore_from_QM_Keystore_Template ($qmname, "b", "c");
    create_QM_CSRs ($qmname, "b", "c");
    sign_QM_CSRs ($qmname, "b", "c");
    import_QM_Certificate_to_QM_Keystores ($qmname, "b", "c");

    my $QM_Keystore_path = "$Keystore_base_path" . "dbs/" . uc($qmname) . "/";
    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
}

sub main () {
    create_retail_store_MQ_server_keystores_S00_QADev ();
    create_retail_store_MQ_server_keystores_Prd ();
=head
    create_a_MQ_server_keystore ();
=cut
}


main ();


