#!/usr/local/bin/bash
CSV_FILE="time_series_covid19_deaths_US_State.csv"
WORKING_PATH="/home/sanpei/src/covid19jp"
to_address="sanpei@sanpei.org"
COVID_CSV_DIR="${WORKING_PATH}/CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series"
COVID_CSV_FILE="time_series_covid19_deaths_US.csv"
DIFF="${CSV_FILE}.diff"

FETCH="/usr/bin/fetch"
MAIL="/usr/bin/mail"
GIT="/usr/local/bin/git"

cd ${WORKING_PATH}
${GIT} pull
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 git pull error" ${to_address}
    exit
fi

cd  ${COVID_CSV_DIR}; ${GIT} pull
if [ $? -ne 0 ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 git pull ERROR" ${to_address}
    exit
fi
if [ ! -s ${COVID_CSV_DIR}/${COVID_CSV_FILE} ]; then
    echo update ${CSV_FILE} | ${MAIL} -s "covid19 download SIZE ZERO ERROR" ${to_address}
    exit
fi

cd ${WORKING_PATH}
/usr/local/bin/ruby case2time_series-US-State_death.rb
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
