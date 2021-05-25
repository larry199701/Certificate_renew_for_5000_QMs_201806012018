#!/bin/sh


#----------------------------------------------------------------------------------------------------------------------------------------
#  Name:        04_cp_keystore_to_target_host_DEV.sh
#  Usage:	1. login to the MQ server
		2. ./04_cp_keystore_to_target_host_DEV.sh <QM_name>
#  Description:         
#      0. check the $QMNAME passed 
#      1. check the target directory: /var/mqm/qmgrs/$QMNAME
#      2. make dir: /var/mqm/qmgrs/$QMNAME/tls
#      3. cp /backup/mq/install/ca2036/20190121/dbs_DEV/$QMNAME/$qmname.* /var/mqm/qmgrs/$QMNAME/tls12/
#      4. ls -l /var/mqm/qmgrs/$QMNAME/tls12/
#  Date:                2019_01
#----------------------------------------------------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------------------------------------------------
# 0. check the $QMNAME passed 
#----------------------------------------------------------------------------------------------------------------------------------------
if [ ${#} -ne 1 ]
then
    echo "Usage: Must provide the QM name."
    echo "Exampe: ././cp_keystore_to_target_host.sh <QM_name>"
    exit 255
fi

QMNAME=$1

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then 
    qmname="$(echo $QMNAME | tr '[A-Z]' '[a-z]')"
elif [[ "$unamestr" == 'AIX' ]]; then
    typeset -l qmname=$QMNAME
fi

#----------------------------------------------------------------------------------------------------------------------------------------
# 1. check the target directory: /var/mqm/qmgrs/$QMNAME
#----------------------------------------------------------------------------------------------------------------------------------------

if [ ! -d "/var/mqm/qmgrs/$QMNAME" ] 
then
   echo "Directory /var/mqm/qmgrs/$QMNAME does not exist! "
   exit 1
fi


#----------------------------------------------------------------------------------------------------------------------------------------
# 2. make dir: /var/mqm/qmgrs/$QMNAME/tls12
#----------------------------------------------------------------------------------------------------------------------------------------

if [ -d "/var/mqm/qmgrs/$QMNAME/tls12" ] 
then
    echo "Directory /var/mqm/qmgrs/$QMNAME/tls12 exists." 
    
else
    mkdir /var/mqm/qmgrs/$QMNAME/tls12
fi

/backup/mq/install/ca2036/20190121/dbs_DEV


ls -l /backup/mq/install/ca2036/20190121/dbs_DEV/$QMNAME/$qmname.*
#----------------------------------------------------------------------------------------------------------------------------------------
# 3. cp /backup/mq/install/ca2036/20190121/dbs_DEV/$QMNAME/$qmname.* /var/mqm/qmgrs/$QMNAME/tls12/
#----------------------------------------------------------------------------------------------------------------------------------------
cp /backup/mq/install/ca2036/20190121/dbs_DEV/$QMNAME/$qmname.* /var/mqm/qmgrs/$QMNAME/tls12/

#----------------------------------------------------------------------------------------------------------------------------------------
# 4. ls -l /var/mqm/qmgrs/$QMNAME/tls12/
#----------------------------------------------------------------------------------------------------------------------------------------

ls -l /var/mqm/qmgrs/$QMNAME/tls12/*



: <<'COMMENT'
COMMENT





