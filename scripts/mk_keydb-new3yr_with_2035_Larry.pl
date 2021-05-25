#!/usr/bin/perl

use strict;

use Getopt::Long;

my $JAR="/usr/java5_64/bin/jar";
my $CA_PASSWD="MQIsTheKey";
my $PASSWD="TheKeyIsAAP";
my $ROPASSWD="MQAccess";

my $GSK7CMD="gsk7cmd";
my $EXPIRE=70;
my $CA_EXPIRE=3650;
my $BASE_DIR="/var/mqm/ca";
my $CA_DIR="$BASE_DIR/ca";
my $KEY_DIR="$BASE_DIR/dbs";
my $TEMPLATE_DIR="$KEY_DIR/KEY-TEMPLATE_2035";
my $CA_LABEL="wmqca_2035";
my $CA_LC_LABEL=lc($CA_LABEL);

my $ECOMM_PASSWD="ECommAccess";

my $KEY="";
my $TYPE="";
my $LC_KEY;
my $CA_LC_KEY;
my $KEY_DB;
my $CA_DB;
my $LABEL;
my $FILE_BASE;
my $REQ_FILE;
my $CERT_FILE;
my $CA_CERT;

$KEY="unknown";
$TYPE="qm";

Getopt::Long::GetOptions(
   'k=s' => \$KEY,
   't=s' => \$TYPE);

printf( "key = $KEY\n");
printf( "type = $TYPE\n");

$LC_KEY=lc($KEY);
$CA_LC_KEY=lc($CA_LABEL);
$KEY_DB=$KEY_DIR."/".$KEY."/".$LC_KEY.".kdb";
$CA_DB=$CA_DIR."/".$CA_LC_LABEL.".kdb";
$LABEL="ibmwebspheremq".$LC_KEY;
$FILE_BASE=$KEY_DIR."/".$KEY."/".$LC_KEY;
$REQ_FILE=$FILE_BASE."req.arm";
$CERT_FILE=$FILE_BASE."cert.arm";
$CA_CERT="ca/ca_cert.arm";

 
#   create_key_dir();
#   create_key_repo();

   if ( $TYPE eq "qm-ssl" || $TYPE eq "qm-tls")
   {
      generate_qm_cert_request(); 
   } 
   elsif ( $TYPE eq "admin-ssl" || $TYPE eq "admin-tls" ) 
   {
      generate_admin_client_cert_request(); 
   }
   elsif ( $TYPE eq "readonly-ssl" ||  $TYPE eq "readonly-tls") 
   {
      my $dn = " CN=".$LC_KEY.",OU=WMQReadonly,O=Advance Auto Parts,C=US";
      generate_cert_request($dn);
   }
   elsif ( $TYPE eq "client-ssl" || $TYPE eq "client-tls")
   {
      generate_app_client_cert_request();
   }
   elsif ( $TYPE eq "ecomm-ssl" || $TYPE eq "ecomm-tls")
   {
      my $dn=" CN=".$LC_KEY.",O=Advance Auto Parts,C=US,OU=WMQEcommerce,OU=WMQReadonly";
      generate_cert_request($dn);
   }

   sign_cert_request();
   import_cert();
   
   if ( ($TYPE eq "readonly-ssl") || ($TYPE eq "ecomm-ssl") ||($TYPE eq "readonly-tls") || ($TYPE eq "ecomm-tls") ) 
   {
   }

   if ( ($TYPE eq "admin-ssl") || ($TYPE eq "client-ssl") || ($TYPE eq "admin-tls") || ($TYPE eq "client-tls") )
   {
   }
 

   if  ($TYPE eq "sign" ) 
   {
       sign_cert_request();
    }




sub generate_qm_cert_request() {
   my $result;
   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US"; 
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);
   return $result;
}

sub generate_admin_client_cert_request() {
   my $result;
   my $dn = " CN=".$LC_KEY.", OU=WMQAdmin, O=Advance Auto Parts, C=US"; 
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -size 2048 -file \"$REQ_FILE\"";
   return $result;
}

sub generate_readonly_client_cert_request() {
   my $result;
   my $cmd;
   my $dn = " CN=".$LC_KEY.", OU=WMQReadonly, O=Advance Auto Parts, C=US";
   $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);
   return $result;
}

sub generate_cert_request() {
   my $result;
   my $cmd;
   my $dn=$_[0];

   #my $dn = " CN=".$LC_KEY.",OU=WMQReadonly,O=Advance Auto Parts,C=US";
   $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);
   return $result;
}

sub generate_app_client_cert_request() {
   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US";
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";
}

sub sign_cert_request() {
   my $result;

   printf("\n###### Start of sign_cert_request() ######\n");
   my $cmd = "$GSK7CMD -cert -sign -file \"$REQ_FILE\" -db \"$CA_DB\" -pw $CA_PASSWD -label $CA_LABEL -target \"$CERT_FILE\" -format ascii -expire $EXPIRE";
   $result=execute($cmd);
   printf("###### End of sign_cert_request() ######\n");
   return $result;
}

sub import_cert() {
   my $result;
   
   printf("\n###### Start of import_cert() ######\n");

   my $cmd = "$GSK7CMD -cert -receive -db \"$KEY_DB\" -pw $PASSWD -file \"$CERT_FILE\" -format ascii";
   $result=execute($cmd);
   printf("###### End of import_cert() ######\n");
   return $result;
}

sub import_ca_cert() {
   my $result;

   printf("\n###### Start of import_ca_cert() ######\n");
   my $cmd = "$GSK7CMD -cert -add -db \"$KEY_DB\" -pw $PASSWD -label $CA_LABEL -file \"$CA_CERT\" -format ascii";
   $result=execute($cmd);
   printf("###### End of import_ca_cert() ######\n");
   return $result;
}

sub execute() {
   my $cmd=$_[0];
   my $result;

   printf("Command is: ".$cmd."\n");
   $result=`$cmd`;
   printf("Result is: ".$result."\n");
   return $result;
}





   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US";
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";

   my $dn = " CN=".$LC_KEY.", OU=WMQAdmin, O=Advance Auto Parts, C=US";
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -size 2048 -file \"$REQ_FILE\"";


   my $dn = " CN=".$LC_KEY.",OU=WMQReadonly,O=Advance Auto Parts,C=US";
   $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";


   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US";
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -dn \"$dn\" -file \"$REQ_FILE\"";
