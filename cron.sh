#!/bin/sh
GIT="/usr/local/bin/git"
COVID_CSV_FILE="COVID-19.csv"
cd /home/sanpei/src/covid19jp/CSSEGISandData/COVID-19/ ; ${GIT} pull
cd /home/sanpei/src/covid19jp/CSSEGISandData/COVID-19/csse_covid_19_data ; ${GIT} pull
cd /home/sanpei/src/covid19jp
/bin/rm ${COVID_CSV_FILE}
${GIT} pull
/usr/local/bin/ruby rapper.rb
cd contents/sanpei3.github.io
/bin/cp covid19jp-100-33.html index.html
/bin/cp covid19jp-150-US-en.html covid19.html
${GIT} commit -m "`/bin/date`" covid19jp-1.html covid19jp-10.html covid19jp-100.html covid19jp-20.html covid19jp-30.html covid19jp-40.html covid19jp-50.html covid19jp-60.html covid19jp-70.html covid19jp-80.html covid19jp-90.html index.html covid19jp-1-33.html covid19jp-10-33.html covid19jp-100-33.html covid19jp-20-33.html covid19jp-30-33.html covid19jp-40-33.html covid19jp-50-33.html covid19jp-60-33.html covid19jp-70-33.html covid19jp-80-33.html covid19jp-90-33.html covid19jp-1-33-en.html covid19jp-1-en.html covid19jp-10-33-en.html covid19jp-10-en.html covid19jp-100-33-en.html covid19jp-100-en.html covid19jp-20-33-en.html covid19jp-20-en.html covid19jp-30-33-en.html covid19jp-30-en.html covid19jp-40-33-en.html covid19jp-40-en.html covid19jp-50-33-en.html covid19jp-50-en.html covid19jp-60-33-en.html covid19jp-60-en.html covid19jp-70-33-en.html covid19jp-70-en.html covid19jp-80-33-en.html covid19jp-80-en.html covid19jp-90-33-en.html covid19jp-90-en.html covid19jp-150-33-en.html  covid19jp-150-en.html covid19jp-150-33.html     covid19jp-150.html covid19.html covid19jp-100-US-en.html covid19jp-100-US-ja.html covid19jp-100-WW-en.html covid19jp-100-WW-ja.html covid19jp-150-US-en.html covid19jp-150-US-ja.html covid19jp-150-WW-en.html covid19jp-150-WW-ja.html
${GIT} push -u origin master
cd /usr/home/sanpei/src/covid19jp
#/usr/local/bin/ruby CSSEGISandData.rb > /home/sanpei/public_html/tmp/hoge.html
