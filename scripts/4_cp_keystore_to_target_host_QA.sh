#!/bin/sh


#----------------------------------------------------------------------------------------------------------------------------------------
#  Name:                cp_keystore_to_target_host.sh
#  Usage:               ./cp_keystore_to_target_host.sh <QM_name>
#  Description:         
#      0. check the $QMNAME passed 
#      1. check the target directory: $mqmpath/mqm/qmgrs/$QMNAME
#      2. make dir: $mqmpath/mqm/qmgrs/$QMNAME/tls
#      3. cp /backup/mq/install/ca2035/20180222/dbs_QA/$QMNAME/$qmname.* $mqmpath/mqm/qmgrs/$QMNAME/tls/
#      4. ls -l $mqmpath/mqm/qmgrs/$QMNAME/tls/
#  Date:                2018_06
#----------------------------------------------------------------------------------------------------------------------------------------

mqmpath="/var"
#mqmpath="/MQHA"

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
# 1. check the target directory: $mqmpath/mqm/qmgrs/$QMNAME
#----------------------------------------------------------------------------------------------------------------------------------------

if [ ! -d "$mqmpath/mqm/qmgrs/$QMNAME" ] 
then
   echo "Directory $mqmpath/mqm/qmgrs/$QMNAME does not exist! "
   exit 1
fi


#----------------------------------------------------------------------------------------------------------------------------------------
# 2. make dir: $mqmpath/mqm/qmgrs/$QMNAME/tls
#----------------------------------------------------------------------------------------------------------------------------------------

if [ -d "$mqmpath/mqm/qmgrs/$QMNAME/tls" ] 
then
    echo "Directory $mqmpath/mqm/qmgrs/$QMNAME/tls exists." 
    
else
    mkdir $mqmpath/mqm/qmgrs/$QMNAME/tls
fi

ls -l /backup/mq/install/ca2035/20180222/dbs_QA/$QMNAME/$qmname.*
#----------------------------------------------------------------------------------------------------------------------------------------
# 3. cp /backup/mq/install/ca2035/20180222/dbs_QA/$QMNAME/$qmname.* $mqmpath/mqm/qmgrs/$QMNAME/tls/
#----------------------------------------------------------------------------------------------------------------------------------------
cp /backup/mq/install/ca2035/20180222/dbs_QA/$QMNAME/$qmname.* $mqmpath/mqm/qmgrs/$QMNAME/tls/

#----------------------------------------------------------------------------------------------------------------------------------------
# 4. ls -l $mqmpath/mqm/qmgrs/$QMNAME/tls/
#----------------------------------------------------------------------------------------------------------------------------------------

ls -l $mqmpath/mqm/qmgrs/$QMNAME/tls/*



: <<'COMMENT'
COMMENT





