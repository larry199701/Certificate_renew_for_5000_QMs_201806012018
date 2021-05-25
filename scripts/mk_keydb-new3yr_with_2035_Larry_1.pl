#!/usr/bin/perl

use strict;

use Getopt::Long;

my $JAR="/usr/java5_64/bin/jar";
my $CA_PASSWD="MQIsTheKey_2035";
my $PASSWD="TheKeyIsAAP";
my $ROPASSWD="MQAccess";

my $GSK7CMD="gsk7cmd";
my $EXPIRE=1460;
my $CA_EXPIRE=3650;
my $BASE_DIR="/var/mqm/ca";
my $CA_DIR="$BASE_DIR/ca";
my $KEY_DIR="$BASE_DIR/dbs_test";
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


if ( $KEY eq "unknown" ) 
{
  printf( "\nKey not specified. You must specify a key of either the queue manager name or the client user id.\n");
  display_usage();
  exit 1;
}

if ( ( $TYPE ne "client-ssl") && ( $TYPE ne "qm-ssl" ) && ( $TYPE ne "admin-ssl" ) && ( $TYPE ne "sign" ) && ( $TYPE ne "readonly-ssl" ) && ( $TYPE ne "ecomm-ssl" ) && ( $TYPE ne "client-tls") && ( $TYPE ne "qm-tls" ) && ( $TYPE ne "admin-tls" ) && ( $TYPE ne "readonly-tls" ) && ( $TYPE ne "ecomm-tls"
))
{
   printf( "\nInvalid type. Valid types are \n\"readonly-ssl\"\n\"qm-ssl\"\n \"client-ssl\"\n\"admin-ssl\"\n\"ecomm-ssl\"\n\"readonly-ssl\"\n\"qm-tls\"\n \"client-tls\"\n\"admin-tls\"\n\"ecomm-tls\"\ .\n");
   display_usage();
   exit 2;
}   

$LC_KEY=lc($KEY);
$CA_LC_KEY=lc($CA_LABEL);
$KEY_DB=$KEY_DIR."/".$KEY."/".$LC_KEY.".kdb";
$CA_DB=$CA_DIR."/".$CA_LC_LABEL.".kdb";
$LABEL="ibmwebspheremq".$LC_KEY;
$FILE_BASE=$KEY_DIR."/".$KEY."/".$LC_KEY;
$REQ_FILE=$FILE_BASE."req.arm";
$CERT_FILE=$FILE_BASE."cert.arm";
$CA_CERT="ca/ca_cert.arm";

   print_variables();
   create_key_dir();
   create_key_repo();

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
      #my $dn="CN=".$LC_KEY.",OU=WMQEcommerce,O=Advance Auto Parts,C=US";
      generate_cert_request($dn);
      #generate_readonly_client_cert_request(); 
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
      change_cert_passwd($PASSWD, $ROPASSWD); 
      convert_cert_to_jks($ROPASSWD);
   }

   if ( ($TYPE eq "admin-ssl") || ($TYPE eq "client-ssl") || ($TYPE eq "admin-tls") || ($TYPE eq "client-tls") )
   {
      convert_cert_to_jks($PASSWD);
   }
 
   zip_package();
   
   if ( $TYPE eq "readonly-ssl" || $TYPE eq "ecomm-ssl" || $TYPE eq "admin-ssl" || $TYPE eq "readonly-tls" || $TYPE eq "ecomm-tls" || $TYPE eq "admin-tls") 
   {
      email_keystore($LC_KEY);
   } 
    
if  ($TYPE eq "sign" ) 
{
   sign_cert_request();
}


sub print_variables() {
   printf("\n");
   printf("Key db: ".$KEY_DB."\n");
   printf("Label: ".$LABEL."\n");
   printf("Password: ".$PASSWD."\n");
   printf("\n");
}

sub trim($) {
   my $string = shift;
   $string =~ s/^\s+//;
   $string =~ s/\s+$//;
   return $string;
}

sub email_keystore() 
{
   my $cmd;
   my $user = $_[0];
   my $email = "$user\@advance-auto.com";
   my $fromemail = "HTS_MQ\@advance-auto.com";

   $cmd = "uuencode $KEY_DIR/zipfiles/$TYPE/$user.zip $user.zip > $user.tmp; uuencode /var/mqm/ca/scripts/$TYPE.pdf ".$TYPE."_install_notes.pdf >> $user.tmp; uuencode $BASE_DIR/Read_First.txt Read_First.txt >> $user.tmp; uuencode /var/mqm/ca/scripts/MQ_Explorer_Upgrade_Steps.pdf MQ_Explorer_Upgrade_Steps.pdf >> $user.tmp; cat $user.tmp | mail -s \"IBM MQ Keystore $TYPE\" -r $fromemail $email";
   my $result = execute($cmd);
   return $result;
}

sub change_cert_passwd() 
{
   my $cmd;
   my $OLD_PW=$_[0];
   my $NEW_PW=$_[1];

   $cmd = "$GSK7CMD -keydb -changepw -db \"$KEY_DB\" -pw $OLD_PW -new_pw $NEW_PW -expire $EXPIRE -stash"; 
   my $result= execute($cmd);
   return $result; 
}

sub convert_cert_to_jks() 
{
   my $cmd;
   my $PW=$_[0]; 

   $cmd = "$GSK7CMD -keydb -convert -db \"$KEY_DB\" -pw $PW -old_format cms -new_format JKS";
   my $result= execute($cmd);
   return $result; 
}

sub create_key_repo() {
   my @filelist = ("kdb", "sth", "rdb", "crl");
   my $cmd;
   my $result;
   my $ext;

   printf("\n###### Start of create_key_repo() ######\n");
  # my $cmd = "$GSK7CMD -keydb -create -db \"$KEY_DB\" -pw $PASSWD -type cms -expire $EXPIRE -stash";
  # return execute($cmd);
   
   foreach $ext ( @filelist ) {
      $cmd="cp $TEMPLATE_DIR/key-template.$ext ".$KEY_DIR."/".$KEY."/".$LC_KEY.".".$ext;
      $result=execute($cmd); 
   } 
   printf("###### End of create_key_repo() ######\n");
}

sub create_ca_repo() {
   my $result;
   my $cmd;
   printf("\n###### Start of create_ca_repo() ######\n");
   $cmd = "$GSK7CMD -keydb -create -db \"$CA_DB\" -pw $CA_PASSWD -type cms -expire $CA_EXPIRE -stash";
   $result=execute($cmd); 
   printf("###### End of create_ca_repo() ######\n");
   return $result;
}

sub create_key_dir() {
   my $cmd;
   my $result;

   printf("\n###### Start of create_key_dir() ######\n");

   $cmd = "rm -rf ".$KEY_DIR."/".$KEY."/";
   $result=execute($cmd);
   
   $cmd = "mkdir ".$KEY_DIR."/".$KEY."/";
   $result=execute($cmd);
   printf("###### End of create_key_dir() ######\n");
   return $result;
}


sub generate_qm_cert_request() {
   my $result;
   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US"; 

   printf("\n###### Start of generate_cert_request() ######\n");
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -size 2048 -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);
   printf("###### End of generate_cert_request() ######\n");
   printf("$cmd\n");
   return $result;
}

sub generate_admin_client_cert_request() {
   my $result;
   my $dn = " CN=".$LC_KEY.", OU=WMQAdmin, O=Advance Auto Parts, C=US"; 
  
   printf("\n###### Start of generate_admin_client_request() ######\n");
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -size 2048 -dn \"$dn\" -size 2048 -file \"$REQ_FILE\"";
   $result= execute($cmd);
   printf("###### End of generate_admin_client_request() ######\n");

   return $result;
}

sub generate_readonly_client_cert_request() {
   my $result;
   my $cmd;

   my $dn = " CN=".$LC_KEY.", OU=WMQReadonly, O=Advance Auto Parts, C=US";

   printf("\n###### Start of generate_readonly_client_request() ######\n");

   $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -size 2048 -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);

   printf("###### End of generate_readonly_client_request() ######\n");
   return $result;
}

sub generate_cert_request() {
   my $result;
   my $cmd;
   my $dn=$_[0];

   #my $dn = " CN=".$LC_KEY.",OU=WMQReadonly,O=Advance Auto Parts,C=US";

   printf("\n###### Start of generate_cert_request() ######\n");

   $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -size 2048 -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);

   printf("###### End of generate_cert_request() ######\n");
   return $result;
}

sub generate_app_client_cert_request() {
   my $result;
   my $dn = " CN=".$LC_KEY.", OU=WMQ, O=Advance Auto Parts, C=US";
  
   printf("\n###### Start of generate_admin_client_request() ######\n");
   my $cmd = "$GSK7CMD -certreq -create -db \"$KEY_DB\" -pw $PASSWD -label $LABEL -size 2048 -dn \"$dn\" -file \"$REQ_FILE\"";
   $result= execute($cmd);
   printf("###### End of generate_admin_client_request() ######\n");
   return $result;
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

sub list_all_CAs() {
   my $result;

   printf("\n###### Start of list_all_CAs() ######\n");
   my $cmd = "$GSK7CMD -cert -list -db \"$KEY_DB\" -pw $PASSWD | grep -iv $KEY > \"$KEY_DIR\"";
   $result=execute($cmd);
   printf("###### End of list_all_CAs() ######\n");
   return $result;
}

sub zip_package() {
   my $result;
   my $cmd;

   printf("\n###### Start of zip_package() ######\n");
   my $files = ".";
   $cmd = "rm ".$KEY_DIR."/".$KEY."/*.arm";
   execute("$cmd\n"); 
   $cmd = $JAR." -cvfM $KEY_DIR/zipfiles/".$TYPE."/".$KEY.".zip -C ".$KEY_DIR."/".$KEY." ".$files;
   $result=execute($cmd);
   printf("###### End of zip_package() ######\n");
   return $result;
}

sub remove_all_CAs() {
   my $cmd;
   my $result;
   my $record;

   printf("\n###### Start remove_all_CAs ######\n");
   open(CALIST, "ca/ca.list");
   while ( $record = <CALIST>) {
      $record = trim($record);
      print $record."\n";
      $cmd = "$GSK7CMD -cert -delete -db \"$KEY_DB\" -pw $PASSWD -label \"$record\"";
      $result=execute($cmd); 
   }
   close(CALIST);
   printf("###### End remove_all_CAs ######\n");
}

sub display_usage() {
   printf("\nUsage: $0 -k KEY [-t TYPE]\n\nExample: $0 -k DR01 -t qm-ssl\n");
}
sub execute() {
   my $cmd=$_[0];
   my $result;

   printf("Command is: ".$cmd."\n");
   $result=`$cmd`;
   printf("Result is: ".$result."\n");
   return $result;
}

=head
=cut
