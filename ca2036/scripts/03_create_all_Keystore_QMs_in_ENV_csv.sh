#!/bin/sh


if [ ${#} -ne 1 ]
then
    echo "Usage: Must provide the list of QMs csv file name."
    echo "Exampe: ./03_create_all_QM_certificates_in_env.sh /var/mqm/ca/ca2036/20180222/dbs_DEV_old/mqserverlist_QA_all.csv "
    exit 255
fi

while IFS=, read -r a b;
do
    echo "$a"
    ./02_mk_Keystore_QM_from_Template_2036_sign_with_CA_2036.pl -k "$a"
done < $1



