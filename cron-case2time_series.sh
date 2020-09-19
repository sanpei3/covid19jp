#!/usr/local/bin/bash
CSV_FILE="time_series_covid19_confirmed_Japan.csv"
WORKING_PATH=/home/sanpei/src/covid19jp
to_address="sanpei@sanpei.org"
COVID_CSV_FILE="COVID-19.csv"
URL="https://dl.dropboxusercontent.com/s/6mztoeb6xf78g5w/${COVID_CSV_FILE}"
DIFF="${CSV_FILE}.diff"

CURL="/usr/local/bin/curl"
FETCH="/usr/bin/fetch"
MAIL="/usr/bin/mail"
GIT="/usr/local/bin/git"

cd ${WORKING_PATH}
/bin/rm ${COVID_CSV_FILE}
${GIT} pull
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 git pull error" ${to_address}
    exit
fi

#${CURL} -o ${COVID_CSV_FILE} ${URL}
# currently I cannot find the way to get error code. so I use fetch in FreeBSD
${FETCH} ${URL}
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 download ERROR" ${to_address}
    exit
fi
if [ ! -s ${COVID_CSV_FILE} ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 download SIZE ZERO ERROR" ${to_address}
    exit
fi

/usr/local/bin/ruby case2time_series.rb
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 ERROR" ${to_address}
    exit
fi
if [ ! -s ${CSV_FILE} ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 SIZE ZERO ERROR" ${to_address}
    exit
fi
${GIT} diff ${CSV_FILE} > ${DIFF}
if [ ! -s ${DIFF} ]; then
	exit
fi
${GIT} commit -uno -m "`/bin/date`" ${CSV_FILE}
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 git commit error" ${to_address}
    exit
fi
${GIT} push -u origin master
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 git push error" ${to_address}
    exit
fi
