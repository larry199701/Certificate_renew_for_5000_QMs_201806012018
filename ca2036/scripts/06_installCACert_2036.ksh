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


mqmpath="/var"
#mqmpath="/MQHA"
Keystore_pass=TheKeyIsAAP
CA_2036_LABEL=wmqca_2036
CA_2036_FILE=/backup/mq/install/ca2036/wmqca_2036/wmqca_2036.arm
DATE=`date +"%Y%M%d%H%m%S`



MQ_WORK_PATH=/var/mqm/qmgrs/$QMNAME/tls
#echo `ls -l $MQ_WORK_PATH`

#----------------------------------------------------------------------------------------------------------------------------------------
# 1. Backup /var/mqm/qmgrs/$QMNAME/tls/* files
#----------------------------------------------------------------------------------------------------------------------------------------
if [[ ! -d $MQ_WORK_PATH ]]; then
   echo "MQ_WORK_PATH $MQ_WORK_PATH does not exist."
   exit 2
fi

mkdir -p $MQ_WORK_PATH/save
if [[ $? -ne 0 ]]; then
   echo "Error creating $MQ_WORK_PATH/save directory"
   exit 2
fi

# Backup the keystores...
cp $MQ_WORK_PATH/$qmname.crl $MQ_WORK_PATH/save/$qmname.crl$DATE
cp $MQ_WORK_PATH/$qmname.kdb $MQ_WORK_PATH/save/$qmname.kdb$DATE
cp $MQ_WORK_PATH/$qmname.rdb $MQ_WORK_PATH/save/$qmname.rdb$DATE
cp $MQ_WORK_PATH/$qmname.sth $MQ_WORK_PATH/save/$qmname.sth$DATE

#echo `ls -l $MQ_WORK_PATH/save`

#----------------------------------------------------------------------------------------------------------------------------------------
# 2. Remove $CA_2036_LABEL from $MQ_WORK_PATH/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------

echo
CMD="runmqakm -cert -list -db $MQ_WORK_PATH/$qmname.kdb -pw $Keystore_pass | grep $CA_2036_LABEL"
echo CMD: $CMD
eval $CMD > /dev/null
if [[ $? -eq 0 ]]
then
    echo
    echo Found existing instance of $CA_2036_LABEL in keystore. Removng old ca cert
    CMD="runmqakm -cert -delete -label $CA_2036_LABEL -db $MQ_WORK_PATH/$qmname.kdb -pw $Keystore_pass"
    echo CMD: $CMD
    eval $CMD
else
    echo "$CA_2036_LABEL is not in $MQ_WORK_PATH/$qmname.kdb"
fi

#----------------------------------------------------------------------------------------------------------------------------------------
# 3. Add $CA_2036_LABEL to $MQ_WORK_PATH/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------

CMD="runmqakm -cert -add -label $CA_2036_LABEL -file $CA_2036_FILE -db $MQ_WORK_PATH/$qmname.kdb -pw $Keystore_pass"
echo CMD: $CMD
eval $CMD
if [[ $? -eq 0 ]]
then
    echo "$CA_2036_LABEL added to $MQ_WORK_PATH/$qmname.kdb"
else
    echo "Failed to add $CA_2036_LABEL to $MQ_WORK_PATH/$qmname.kdb"
fi

#----------------------------------------------------------------------------------------------------------------------------------------
# 4. List $CA_2036_LABEL in $MQ_WORK_PATH/$qmname.kdb
#----------------------------------------------------------------------------------------------------------------------------------------
CMD="runmqakm -cert -details -label $CA_2036_LABEL -db $MQ_WORK_PATH/$qmname.kdb -pw $Keystore_pass"
echo CMD: $CMD
eval $CMD

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






:<<COMMENT
COMMENT

