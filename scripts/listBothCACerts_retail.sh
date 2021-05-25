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




echo "===================================================================================================================================="
CMD="runmqakm -cert -details -label $CA_LABEL_2035 -db /var/mqm/ca/dbs/$QM/$MQ_LC.kdb -pw $PW"
echo CMD: $CMD
eval $CMD
echo
echo "===================================================================================================================================="

CMD="runmqakm -cert -details -label $CA_LABEL -db /var/mqm/ca/dbs/$QM/$MQ_LC.kdb -pw $PW"
echo CMD: $CMD
eval $CMD
echo "===================================================================================================================================="
