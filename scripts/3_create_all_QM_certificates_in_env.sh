#!/bin/sh


if [ ${#} -ne 1 ]
then
    echo "Usage: Must provide the list of QMs csv file name."
    echo "Exampe: ./3_create_all_QM_certificates_in_env.sh /var/mqm/ca/ca2035/20180222/dbs_DEV_old/mqserverlist_QA_all.csv "
    exit 255
fi

while IFS=, read -r a b;
do
    echo "$a"
    /backup/mq/install/ca2035/ca_keystores_2035/2_create_Retail_QMs_keystores_from_template_2035_current_CA.pl -k "$a"
done < $1



