#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name:         02_mk_Keystore_QM_from_Template_2036_sign_with_CA_2036.pl
#  Usage:        "./02_mk_Keystore_QM_from_Template_2036_sign_with_CA_2036.pl -k <QMNAME>"
#  Description:  corp, retail qmgr keystores
#      0. Test the command line arguments
#      1. copy_Keystore_QM_from_Keystore_Template ()
#      2. create_QM_CSRs, label: "ibmwebspheremq" . lc($qmname)
#      3. sign the CSR with the new keystore: wmqca_2036.kdb, create a new certificate
#      4. import_QM_Certificate_to_QM_Keystores 
#  Date:                2015_08
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;
use Getopt::Long;

my $Keystore_QMs_path = "/backup/mq/install/ca2036/20190121/";
my $Keystore_Template_path = "/backup/mq/install/ca2036/wmqca_2036/";
my $Keystore_Template_name = "AAPMQ_Keystore_Template_2036";
my $Keystore_Template_pass = "TheKeyIsAAP";
my $env = "DEV";
my $QM;
my $KEYMGRCMD = "runmqckm";
my $SIGALG = "SHA256_WITH_RSA";
my $CA_Label = "wmqca_2036";
my $Keystore_CA_path = "/backup/mq/install/ca2036/wmqca_2036/";
my $Keystore_CA_name = "AAPMQ_Keystore_CA_2036.kdb";
my $Keystore_CA_pass = "MQIsTheKey2036";
my $QM_Cert_Expire = 1460;


GetOptions ("k=s" => \$QM) or die ("ERROR: unsupported option.");
die("ERROR: qm must be specified. \nUsage: $0 -k QM\nExample: $0 -k DR01\n\n") unless defined $QM;

sub copy_Keystore_QM_from_Keystore_Template {
    my ($qmname, $env) = @_;
    my $Keystore_QM_path = "$Keystore_QMs_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $cmd = "mkdir -p " . $Keystore_QM_path;
    system($cmd);

    $cmd = "cp $Keystore_Template_path"."$Keystore_Template_name".".kdb "."$Keystore_QM_path". lc($qmname) . ".kdb";
    system($cmd);
    $cmd = "cp $Keystore_Template_path"."$Keystore_Template_name".".rdb "."$Keystore_QM_path". lc($qmname) . ".rdb";
    system($cmd);
    $cmd = "cp $Keystore_Template_path"."$Keystore_Template_name".".sth "."$Keystore_QM_path". lc($qmname) . ".sth";
    system($cmd);
    print "\nmqlog----: " . "$Keystore_QM_path". lc($qmname) . ".kdb" . " has been copied. \n";
}

sub create_Keystore_QM_CSR {
    my ($qmname, $env) = @_;
    my $Keystore_QM_path = "$Keystore_QMs_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $QM_Key_Label = "ibmwebspheremq" . lc($qmname);
    my $QM_DN = "CN=" . lc ($qmname) . ",OU=WMQ,O=Advance Auto Parts,C=US";
    my $Keystore_CSR_File = "$Keystore_QM_path" .  lc($qmname) . "ibmwebspheremq" . $qmname . "_req.arm";

    my $cmd = "$KEYMGRCMD -certreq -create -db $Keystore_QM_path" . lc($qmname) . ".kdb -pw $Keystore_Template_pass -label $QM_Key_Label -size 2048 -dn '$QM_DN' -file $Keystore_CSR_File -sig_alg $SIGALG";
    (`$cmd` eq "") || die ("\nmqlog----: Could not create QM CSR $QM_Key_Label from $Keystore_QM_path" . lc($qmname) . ".kdb\n");
    print "\nmqlog----: the QM CSR $QM_Key_Label has been created from $Keystore_QM_path" . lc($qmname) . ".kdb to $Keystore_CSR_File\n";
}

sub sign_Keystore_CSR {
    my ($qmname, $env) = @_;
    my $Keystore_QM_path = "$Keystore_QMs_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $Keystore_CSR_File = "$Keystore_QM_path" .  lc($qmname) . "ibmwebspheremq" . $qmname . "_req.arm";
    my $Keystore_Crt_File = "$Keystore_QM_path" .  lc($qmname) . "ibmwebspheremq" . $qmname . "_crt.arm";

    my $cmd = "$KEYMGRCMD -cert -sign -file $Keystore_CSR_File -db $Keystore_CA_path" . "$Keystore_CA_name -pw $Keystore_CA_pass -label $CA_Label -target $Keystore_Crt_File -format ascii -expire $QM_Cert_Expire";
    (`$cmd` eq "") || die ("\nmqlog----: Could not sign the CSR: $Keystore_CSR_File using CA Label: $CA_Label in CA Keystore: $Keystore_CA_name . \n");
    print "\nmqlog----: the QM CSR $Keystore_CSR_File has been signed and the QM Cert file: $Keystore_Crt_File has been created. \n";
}

sub import_Keystore_QM_Crt_to_Keystore_QM {
    my ($qmname, $env) = @_;
    my $Keystore_QM_path = "$Keystore_QMs_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $Keystore_Crt_File = "$Keystore_QM_path" .  lc($qmname) . "ibmwebspheremq" . $qmname . "_crt.arm";

    my $cmd = "$KEYMGRCMD -cert -receive -db $Keystore_QM_path" . lc($qmname) . ".kdb -pw $Keystore_Template_pass -file $Keystore_Crt_File -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not import the Certificate: $Keystore_Crt_File to $Keystore_QM_path" . lc($qmname) . ".kdb. \n");

    print "\nmqlog----: the $Keystore_Crt_File has been imported into $Keystore_QM_path" . lc($qmname) . ".kdb. \n";

    $cmd = "$KEYMGRCMD -cert -list -db $Keystore_QM_path" . lc($qmname) . ".kdb -pw $Keystore_Template_pass";
    print "mqlog----: ", `$cmd`;
}

sub remove_qm_csr_cert_file {
    my ($qmname, $env) = @_;
    my $Keystore_QM_path = "$Keystore_QMs_path" . "dbs_" . "$env/" . uc($qmname) . "/";
    my $Keystore_CSR_File = "$Keystore_QM_path" .  lc($qmname) . "ibmwebspheremq" . $qmname . "_req.arm";
    my $cmd = "rm $Keystore_CSR_File";
    system($cmd);
}


sub create_a_MQ_server_keystore {
    my ($qmname) = @_;
    copy_Keystore_QM_from_Keystore_Template ($qmname, $env);
    create_Keystore_QM_CSR ($qmname, $env);
    sign_Keystore_CSR ($qmname, $env);
    import_Keystore_QM_Crt_to_Keystore_QM ($qmname, $env);
    remove_qm_csr_cert_file ($qmname, $env);
}


sub main () {
    create_a_MQ_server_keystore ($QM);
=head
    create_retail_store_MQ_server_keystores_S00_QADev ();
    create_retail_store_MQ_server_keystores_Prd ();
=cut
}


main ();



=head
sub create_retail_store_MQ_server_keystores_Prd () {
    opendir(SNAME, "/var/mqm/ca/mq_scripts_ca_keystores_2015/expiring_certs/dbs_expired_2015") || die ("Unable to open directory");
    while (my $QMNAME = readdir(SNAME)) {
        if (((substr $QMNAME, 0, 2) eq "S0") and (length($QMNAME) == 7)) {
            if ((substr $QMNAME, 0, 3) ne "S00") {
                my $qmname = lc($QMNAME);
                copy_Keystore_QM_from_Keystore_Template ($qmname, "Prd");
                create_QM_CSRs ($qmname, "Prd");
                sign_QM_CSRs ($qmname, "Prd");
                import_QM_Certificate_to_QM_Keystores ($qmname, "Prd");
                remove_qm_csr_cert_file ("Prd", "b");

                my $QM_Keystore_path = "$Keystore_QMs_path" . "dbs_Prd/" . uc($qmname) . "/";
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
                copy_Keystore_QM_from_Keystore_Template ($qmname, "QADev", "c");
                create_QM_CSRs ($qmname, "QADev");
                sign_QM_CSRs ($qmname, "QADev", "c");
                import_QM_Certificate_to_QM_Keystores ($qmname, "QADev", "c");
                remove_qm_csr_cert_file ("QADev", "b", "c");

                my $QM_Keystore_path = "$Keystore_QMs_path" . "dbs_QADev/" . uc($qmname) . "/";
                my $QM_Keystore_name = $QM_Keystore_path . lc($qmname) . ".kdb";
                print "mqlog----: ", `gsk7cmd -cert -list -db $QM_Keystore_name -pw $QM_Keystore_pass`, "\n";
        }
    }
    closedir(SNAME);
}
=cut
