#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:                create_keystores_from_template.pl
#  Usage:               "./create_keystores_from_template.pl"
#  Description:         Create all CA, corp, retail qmgr keystores
#  Date:                2018_02
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;
use Getopt::Long;

my $Keystore_base_path = "/var/mqm/ca/larry/20180222/";
my $CA_Keystore_name = $Keystore_base_path . "AAPMQ_Keystore_CA_2038";
my $CA_Keystore_pass = "MQIsTheKey_2038";
my $CA_Keystore_Expiredate = 7300;
my $CA_DN = "CN=wmqca_2038, OU=WMQ, O=Advance Stores, L=Roanoke, ST=Virginia, C=US";
my $CA_Label = "wmqca_2038";
my $CA_Label_old = "wmqca";
my $CA_Key_Expiredate = 7299;
my $CA_certificate = "$Keystore_base_path" . "wmqca_2038.crt";
my $CA_certificate_old = "$Keystore_base_path" . "../" . "ca_cert.arm";
my $QM_Keystore_Template_name = $Keystore_base_path . "AAPMQ_Keystore_QM_Template_2038";
my $QM_Keystore_pass = "TheKeyIsAAP";
my $QM_Keystore_Template_Expiredate = 7300;
my $QM_Cert_Expiredate = 1460;
my $env = "DEV";
my $QM;

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Test the command line arguments
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

GetOptions ("k=s" => \$QM) or die ("ERROR: unsupported option.");
die("ERROR: qm must be specified. \nUsage: $0 -k QM\nExample: $0 -k DR01\n\n") unless defined $QM;

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Create QM Keystore from QM Keystore Template, Import CA Public Certificate, Create QM CSR, Sign CSR to QM Certificate, Import QM Certificat
#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sub copy_QM_Keystore_from_QM_Keystore_Template {
    my ($qmname, $env) = @_;
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
    my ($qmname, $env) = @_;
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
    my ($qmname, $env) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_CSR_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_req.arm";
    my $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm";

    my $cmd = "gsk7cmd -cert -sign -file $QM_CSR_File -db $CA_Keystore_name.kdb -pw $CA_Keystore_pass -label $CA_Label -target $QM_Cert_File -format ascii -expire $QM_Cert_Expiredate";

    print $cmd . "\n";
    (`$cmd` eq "") || die ("\nmqlog----: Could not sign the CSR: $QM_CSR_File using CA Label: $CA_Label in CA Keystore: $CA_Keystore_name.kdb. \n");

    print "\nmqlog----: the QM CSR $QM_CSR_File has been signed and the QM Cert file: $QM_Cert_File has been created. \n";
}

sub import_QM_Certificate_to_QM_Keystores {
    my ($qmname, $env) = @_;
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    my $QM_Cert_File = $QM_Keystore_path . "ibmwebspheremq" . $qmname . "_cert.arm";

    my $cmd = "gsk7cmd -cert -receive -db $QM_Keystore_name -pw $QM_Keystore_pass -file $QM_Cert_File -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not import the QM Certificate: $QM_Cert_File  to the QM Keystore: $QM_Keystore_name.  \n");

    print "\nmqlog----: the QM Certificate $QM_Cert_File has been imported into the QM Keystore: $QM_Keystore_name. \n";
}

sub remove_qm_csr_cert_file {
    my ($env, $p2) = @_;
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
                copy_QM_Keystore_from_QM_Keystore_Template ($qmname, "Prd");
                create_QM_CSRs ($qmname, "Prd");
                sign_QM_CSRs ($qmname, "Prd");
                import_QM_Certificate_to_QM_Keystores ($qmname, "Prd");
                remove_qm_csr_cert_file ("Prd", "b");

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
                create_QM_CSRs ($qmname, "QADev");
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

sub create_a_MQ_server_keystore {
    my ($qmname) = @_;
=head
=cut
    copy_QM_Keystore_from_QM_Keystore_Template ($qmname, $env);
    create_QM_CSRs ($qmname, $env);
    sign_QM_CSRs ($qmname, $env);
    import_QM_Certificate_to_QM_Keystores ($qmname, $env);
    my $QM_Keystore_path = "$Keystore_base_path" . "dbs_".$env."/".uc($qmname)."/";
    my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
    print $QM_Keystore_name."______".$QM_Keystore_path;
    print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
=head
=cut
}

sub main () {
=head
    create_retail_store_MQ_server_keystores_S00_QADev ();
    create_retail_store_MQ_server_keystores_Prd ();
    create_a_MQ_server_keystore ("larrydr01");
    create_a_MQ_server_keystore ("larrydr02");
    create_a_MQ_server_keystore ("larrys09999a");
=cut
    create_a_MQ_server_keystore ($QM);
}


main ();


