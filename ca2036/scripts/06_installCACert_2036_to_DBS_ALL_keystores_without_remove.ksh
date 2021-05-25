#!/bin/ksh


DBS_PATH=/var/mqm/ca/dbs
Keystore_pass=TheKeyIsAAP
CA_2036_LABEL=wmqca_2036
CA_2036_FILE=/backup/mq/install/ca2036/wmqca_2036/wmqca_2036.arm
DATE=`date +"%Y%M%d%H%m%S`

#$DBS_PATH/$QMNAME/$qmname.kdb


unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    qmname="$(echo $QMNAME | tr '[A-Z]' '[a-z]')"
elif [[ "$unamestr" == 'AIX' ]]; then
    typeset -l qmname=$QMNAME
fi




for QMNAME in $( ls $DBS_PATH/ ); do

  #----------------------------------------------------------------------------------------------------------------------------------------
  # 1. Verify $DBS_PATH/$QMNAME/$qmname.kdb exist:
  #----------------------------------------------------------------------------------------------------------------------------------------

    echo
    unamestr=`uname`
    if [[ "$unamestr" == 'Linux' ]]; then
        qmname="$(echo $QMNAME | tr '[A-Z]' '[a-z]')"
    elif [[ "$unamestr" == 'AIX' ]]; then
        typeset -l qmname=$QMNAME
    fi

    if [ ! -f "$DBS_PATH/$QMNAME/$qmname.kdb" ]
    then
        echo "file $DBS_PATH/$QMNAME/$qmname.kdb does not exist! "
    exit 1
    fi

    echo `ls -l $DBS_PATH/$QMNAME/$qmname.kdb`
    echo "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

  #----------------------------------------------------------------------------------------------------------------------------------------
  # 2. Add $CA_2036_LABEL from $DBS_PATH/$QMNAME/$qmname.kdb
  #----------------------------------------------------------------------------------------------------------------------------------------

    CMD="runmqakm -cert -list -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass | grep $CA_2036_LABEL"
    echo CMD: $CMD
    eval $CMD > /dev/null
    if [[ $? -eq 0 ]]
    then
        echo Found existing instance of $CA_2036_LABEL in keystore. Removng old ca cert
#        CMD="runmqakm -cert -delete -label $CA_2036_LABEL -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
#        echo CMD: $CMD
        eval $CMD
    else
        echo "$CA_2036_LABEL is not in $DBS_PATH/$QMNAME/$qmname.kdb"

    	CMD="runmqakm -cert -add -label $CA_2036_LABEL -file $CA_2036_FILE -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
        echo CMD: $CMD
        eval $CMD > /dev/null
        if [[ $? -eq 0 ]]
        then
            echo "$CA_2036_LABEL added to $DBS_PATH/$QMNAME/$qmname.kdb"
        else
            echo "Failed to add $CA_2036_LABEL to $DBS_PATH/$QMNAME/$qmname.kdb"
        fi
    fi

  #----------------------------------------------------------------------------------------------------------------------------------------
  # 4. List $CA_2036_LABEL in $DBS_PATH/$QMNAME/$qmname.kdb
  #----------------------------------------------------------------------------------------------------------------------------------------
    CMD="runmqakm -cert -details -label $CA_2036_LABEL -db $DBS_PATH/$QMNAME/$qmname.kdb -pw $Keystore_pass"
#    echo CMD: $CMD
#    eval $CMD


done


#   OFILE=$(echo $FILE | awk -F \/ '{ print $7}' )
#   CMD="cp $MQ_WORK_PATH/$OFILE $MQ_WORK_PATH/save/$OFILE-$DATE"
#   echo $CMD
  # eval $CMD


