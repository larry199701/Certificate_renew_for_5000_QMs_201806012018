#!/bin/ksh

#----------------------------------------------------------------------------------------------------------------------------------------
#  Name:                06_installCACert_2036.sh
#  Usage:               ./06_installCACert_2036.sh <QM_name>
#  Description:
#      0. check the $QMNAME passed
#      1. check the target directory: $mqmpath/mqm/qmgrs/$QMNAME
#      2. Switch QM keystore & Refresh security
#  Date:                2019_01
#----------------------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------------------
# 0. check the $QMNAME passed
#----------------------------------------------------------------------------------------------------------------------------------------
if [ ${#} -ne 1 ]
then
    echo "Usage: Must provide the QM name."
    echo "Exampe: ./06_installCACert_2036.sh <QM_name>"
    exit 255
fi

QMNAME=$1

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    qmname="$(echo $QMNAME | tr '[A-Z]' '[a-z]')"
elif [[ "$unamestr" == 'AIX' ]]; then
    typeset -l qmname=$QMNAME
fi


DBS_PATH=/var/mqm/ca/dbs
Keystore_pass=TheKeyIsAAP
CA_2036_LABEL=wmqca_2036
CA_2036_FILE=/backup/mq/install/ca2036/wmqca_2036/wmqca_2036.arm
DATE=`date +"%Y%M%d%H%m%S`

#----------------------------------------------------------------------------------------------------------------------------------------
# 1. Verify $DBS_PATH/$QMNAME/$qmname.kdb exist:
#----------------------------------------------------------------------------------------------------------------------------------------
if [[ ! -f $DBS_PATH/$QMNAME/$qmname.kdb ]]; then
   echo "QMNAME: $DBS_PATH/$QMNAME/$qmname.kdb does not exist."
   exit 2
fi

#----------------------------------------------------------------------------------------------------------------------------------------
# 2. Remove $CA_2036_LABEL from $DBS_PATH/$QMNAME/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------

echo
CMD="runmqakm -cert -list -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass | grep $CA_2036_LABEL"
echo CMD: $CMD
eval $CMD > /dev/null
if [[ $? -eq 0 ]]
then
    echo
    echo Found existing instance of $CA_2036_LABEL in keystore. Removng old ca cert
    CMD="runmqakm -cert -delete -label $CA_2036_LABEL -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
    echo CMD: $CMD
    eval $CMD
else
    echo "$CA_2036_LABEL is not in $DBS_PATH/$QMNAME/$qmname.kdb"
fi

#----------------------------------------------------------------------------------------------------------------------------------------
# 3. Add $CA_2036_LABEL to $DBS_PATH/$QMNAME/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------

CMD="runmqakm -cert -add -label $CA_2036_LABEL -file $CA_2036_FILE -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
echo CMD: $CMD
eval $CMD
if [[ $? -eq 0 ]]
then
    echo "$CA_2036_LABEL added to $DBS_PATH/$QMNAME/$qmname.kdb"
else
    echo "Failed to add $CA_2036_LABEL to $DBS_PATH/$QMNAME/$qmname.kdb"
fi


#----------------------------------------------------------------------------------------------------------------------------------------
# 4. List $CA_2036_LABEL in $DBS_PATH/$QMNAME/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------
CMD="runmqakm -cert -details -label $CA_2036_LABEL -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
echo CMD: $CMD
eval $CMD



:<<COMMENT
echo ""
echo "mylog-----------: before refresh cluster:"
echo "refresh cluster(CLUSTER.D.CORP) repos(YES)" | runmqsc $QMNAME
echo "mylog-----------: before Refresh Security:"
echo "dis chs(*) where (STATUS EQ RUNNING)" | runmqsc $QMNAME
echo "REFRESH SECURITY(*) TYPE(SSL)" | runmqsc $QMNAME
echo "mylog-----------: refreshing cluster:"
echo "refresh cluster(CLUSTER.D.CORP) repos(YES)" | runmqsc $QMNAME
echo "sleeping 60 seconds"
sleep 60
echo "mylog-----------: after refresh security and refresh cluster:"
echo "dis chs(*) where (STATUS EQ RUNNING)" | runmqsc $QMNAME

MQ_WORK_PATH=/var/mqm/qmgrs//tls
#/var/mqm/ca/dbs/S03079A
COMMENT

