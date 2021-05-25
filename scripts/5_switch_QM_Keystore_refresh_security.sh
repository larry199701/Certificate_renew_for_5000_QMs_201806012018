#!/bin/sh

#----------------------------------------------------------------------------------------------------------------------------------------
#  Name:                5_switch_QM_Keystore_refresh_security.sh
#  Usage:               ./5_switch_QM_Keystore_refresh_security.sh <QM_name>
#  Description:
#      0. check the $QMNAME passed
#      1. check the target directory: $mqmpath/mqm/qmgrs/$QMNAME
#      2. Switch QM keystore & Refresh security
#  Date:                2018_07
#----------------------------------------------------------------------------------------------------------------------------------------

mqmpath="/var"
#mqmpath="/MQHA"

#----------------------------------------------------------------------------------------------------------------------------------------
# 0. check the $QMNAME passed
#----------------------------------------------------------------------------------------------------------------------------------------
if [ ${#} -ne 1 ]
then
    echo "Usage: Must provide the QM name."
    echo "Exampe: ./5_switch_QM_Keystore.sh <QM_name>"
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

if [ ! -d "$mqmpath/mqm/qmgrs/$QMNAME/tls" ]
then
   echo "Directory $mqmpath/mqm/qmgrs/$QMNAME/tls/ does not exist! "
   exit 1
fi

if [ ! -f "$mqmpath/mqm/qmgrs/$QMNAME/tls/$qmname"."kdb" ]
then
   echo "file $mqmpath/mqm/qmgrs/$QMNAME/tls/$qmname.kdb does not exist! "
   exit 1
fi


QMKEYSTORE=$mqmpath/mqm/qmgrs/$QMNAME/tls/$qmname
echo $QMKEYSTORE

#----------------------------------------------------------------------------------------
#
# 2. Switch QM keystore & Refresh security
#
#----------------------------------------------------------------------------------------
echo "
ALTER QMGR SSLKEYR('$QMKEYSTORE')
REF SECURITY TYPE(SSL)
" > /tmp/switch_QM_$qmname.in
#----------------------------------------------------------------------------------------

echo "Larry-----: before ----------------------------------"
echo "dis qmgr SSLKEYR" | runmqsc $QMNAME

runmqsc $QMNAME < /tmp/switch_QM_$qmname.in;

echo ""
echo ""
echo ""
echo "Larry-----: after ----------------------------------"
echo "dis qmgr SSLKEYR" | runmqsc $QMNAME

:<<COMMENT
COMMENT
