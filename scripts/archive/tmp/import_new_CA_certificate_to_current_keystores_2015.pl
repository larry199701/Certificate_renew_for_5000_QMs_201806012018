#!/usr/bin/perl

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Name: 		import_new_CA_certificate_to_current_keystores.pl
#  Usage:    		"./import_new_CA_certificate_to_current_keystores.pl path_to_QM_keystore_name QM_Keystore_pass"
#  Description:		To import the newly generated CA certificate 2035 to the QM Server Keystores passed to the script as an argument
#  Scope:      		All QM Servers: /var/mqm/ca/dbs/DCWS01A/dcws01a.kdb in cwsappdev01,  
#  Date: 		2015_08
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#use strict;
use warnings;

$numArgs = $#ARGV + 1;
if ($numArgs != 2) {
    print "\n";
    print "\n";
    print "Usage:    ./import_new_CA_certificate_to_current_keystores.pl path_to_QM_keystore_name QM_Keystore_pass" , "\n";
    # for example:   ./import_new_CA_certificate_to_current_keystores.pl  /var/mqm/ca/20153/dbs/S06197A/s06197a.kdb TheKeyIsAAP_2015
    #                ./import_new_CA_certificate_to_current_keystores.pl /var/mqm/ca/dbs/AGENT_SDMQPRD01/agent_sdmqprd01.kdb -pw FTEIsTheWayThingsMov
    #                ./import_new_CA_certificate_to_current_keystores.pl /var/mqm/ca/dbs/DCWS01A/dcws01a.kdb TheKeyIsAAP
    #                gsk7cmd -cert -list -db /var/mqm/ca/dbs/AGENT_SDMQPRD01/agent_sdmqprd01.kdb -pw FTEIsTheWayThingsMov
    #                gsk7cmd -cert -list -db /var/mqm/ca/dbs/DCWS01A/dcws01a.kdb -pw TheKeyIsAAP
    print "\n";
    print "\n";
    exit 1;
}

$QM_keystore_name = $ARGV[0];
$QM_Keystore_pass = $ARGV[1];
$Keystore_base_path = "/var/mqm/ca/mq_scripts_ca_keystores_2015/20158/";
$CA_certificate_file = "$Keystore_base_path" . "wmqca_2035.crt";
$CA_Label_new = "wmqca_2035";


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  sub import_New_CA_Certificate_to_the_QM_Server_Keystores
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub import_New_CA_Certificate_to_the_QM_Server_Keystores {
    print "mqlog----: Before import,  CA certificates in keystore: ", $QM_keystore_name, " --- ", `gsk7cmd -cert -list CA -db $QM_keystore_name -pw $QM_Keystore_pass`;

    $cmd = "gsk7cmd -cert -add -db $QM_keystore_name -pw $QM_Keystore_pass -label $CA_Label_new -file $CA_certificate_file -format ascii";
    (`$cmd` eq "") || die ("\nmqlog----: Could not import the CA Certificate $CA_certificate_file to QM Keystore $QM_keystore_name. \n");
    print "\nmqlog----: the CA Certificate $CA_certificate_file has been imported into  QM Keystore $QM_keystore_name successfully.\n";

    print "mqlog----: After import,  CA certificates in keystore: ", $QM_keystore_name, " --- ", `gsk7cmd -cert -list CA -db $QM_keystore_name -pw $QM_Keystore_pass`;
}


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  sub  list_CA_Certificate_in_QM_Server_Keystores
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub list_CA_Certificate_in_QM_Server_Keystores {
#    print "mqlog----: After import,  the CA certificates in keystore: ", $QM_keystore_name, " --- ", "gsk7cmd -cert -list CA -db $QM_keystore_name -pw $QM_Keystore_pass";
#    print "mqlog----: After import,  the CA certificates in keystore: ", $QM_keystore_name, " --- ", `gsk7cmd -cert -list CA -db $QM_keystore_name -pw $QM_Keystore_pass`;
    print "mqlog----: After import,  the CA certificates in keystore: ", $QM_keystore_name, " --- ", `gsk7cmd -cert -list -db $QM_keystore_name -pw $QM_Keystore_pass`;
}


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  sub  delete_CA_Certificate_in_QM_Server_Keystores
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub delete_CA_Certificate_in_QM_Server_Keystores {

    $cmd = "gsk7cmd -cert -delete -db $QM_keystore_name -pw $QM_Keystore_pass -label $CA_Label_new";
    (`$cmd` eq "") || die ("\nmqlog----: Could not delete the CA Certificate $CA_Label_new from QM Keystore $QM_keystore_name. \n");
    print "\nmqlog----: the CA Certificate $CA_Label_new has been deleted from QM Keystore $QM_keystore_name successfully.\n";

    print "mqlog----: After import,  the CA certificates in keystore: ", $QM_keystore_name, " --- ", `gsk7cmd -cert -list CA -db $QM_keystore_name -pw $QM_Keystore_pass`;
}




#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  sub main ()
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sub main () {
#    import_New_CA_Certificate_to_the_QM_Server_Keystores ();
#    delete_CA_Certificate_in_QM_Server_Keystores ();
    list_CA_Certificate_in_QM_Server_Keystores ();
}


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  main ()
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
main ();


