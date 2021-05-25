#!/bin/sh

PW=TheKeyIsAAP
CA_LABEL_2035=wmqca_2035
CA_LABEL=wmqca

if [[ $# -lt 1 ]]
then
    echo Missing argument
    echo "Usage: $0 <Queue Manger> [SA stand-alone|MI - multi-instance]"
    exit 1
fi

QM=$1
if [[  -z $QM ]]
then
    echo Queue manager name not specified
    echo "Usage: $0 <Queue Manger> [SA stand-alone|MI - multi-instance]"
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


echo "===================================================================================================================================="
CMD="runmqakm -cert -details -label $CA_LABEL_2035 -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW"
echo CMD: $CMD
eval $CMD
echo
echo "===================================================================================================================================="

CMD="runmqakm -cert -details -label $CA_LABEL -db $MQ_WORK_PATH/${MQ_LC}.kdb -pw $PW"
echo CMD: $CMD
eval $CMD
echo "===================================================================================================================================="
