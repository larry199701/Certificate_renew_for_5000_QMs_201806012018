#!/bin/sh

PW=TheKeyIsAAP
CA_LABEL=wmqca_2035
DATE=`date +"%Y%M%d%H%m%S`

function usage {
    echo "Usage: $0 <Queue Manger> [SA stand-alone|MI - multi-instance]"
}

if [[ $# -lt 1 ]]
then
    echo Missing argument
    usage
    exit 1
fi

QM=$1
if [[  -z $QM ]]
then
    echo Queue manager name not specified
    usage
    exit 2
fi
MQ_LC=$( echo $QM | tr '[:upper:]' '[:lower:]')

MODE=$2
if [[ $MODE == "MI" ]]
then
   MQ_WORK_PATH=/MQHA/mqm/qmgrs/$QM/ssl
else
   MQ_WORK_PATH=/var/mqm/qmgrs/$QM/ssl
fi

if [[ ! -d $MQ_WORK_PATH ]]; then
   echo "MQ_WORK_PATH $MQ_WORK_PATH does not exist. Possibly a multi-instance queue manager." 
   exit 2
fi

mkdir -p $MQ_WORK_PATH/save
RC=$?
if [[ $RC -ne 0 ]]; then
   echo "Error creating $MQ_WORK_PATH/save directory"
   exit 2
fi

for FILE in $( ls $MQ_WORK_PATH/$MQ_LC.* ); do
   OFILE=$(echo $FILE | awk -F \/ '{ print $7}' )
   CMD="cp $MQ_WORK_PATH/$OFILE $MQ_WORK_PATH/save/$OFILE-$DATE"
   echo $CMD
   eval $CMD
done

echo
CMD="runmqakm -cert -list -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW | grep $CA_LABEL"
echo CMD: $CMD
eval $CMD > /dev/null
RC=$?
if [[ $RC -eq 0 ]]
then
    echo
    echo Found existing instance of $CA_LABEL in keystore. Removng old ca cert
    CMD="runmqakm -cert -delete -label $CA_LABEL -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW"
    echo CMD: $CMD
    eval $CMD
fi

CMD="runmqakm -cert -add -label $CA_LABEL -file /backup/mq/install/ca_cert/$CA_LABEL.arm -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW"
echo CMD: $CMD
eval $CMD

CMD="runmqakm -cert -details -label $CA_LABEL -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW"
echo CMD: $CMD
eval $CMD

echo "REFRESH SECURITY(*) TYPE(SSL)" | runmqsc $QM
