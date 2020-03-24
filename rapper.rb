# coding: utf-8
require 'digest/md5'

source_url = "https://dl.dropboxusercontent.com/s/6mztoeb6xf78g5w/COVID-19.csv"
md5_filename = "COVID-19.md5"
csv_filename = "COVID-19.csv"
base_values = [1,10,20,30,40,50,60,70,80,90,100]

md5_old = ""
if (!File.exist?(md5_filename))
  File.new(md5_filename, "w")
end

File.open(md5_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_old = oneline
  end
end
#
sleep(rand(20))
#
# 1. curl file
system("/usr/local/bin/curl -o #{csv_filename} #{source_url}")

# 変化があったか確認
csv = ""
File.open(csv_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5 = Digest::MD5.new.update(csv).to_s
if (md5_old != md5)
  
  #
  #ENV['LANG'] = "ja_JP.UTF-8"
  base_values.each{ |i|
    system("/usr/local/bin/ruby covid19.rb #{i} NO -ja true > contents/sanpei3.github.io/covid19jp-#{i}.html")
    system("/usr/local/bin/ruby covid19.rb #{i} YES -ja true> contents/sanpei3.github.io/covid19jp-#{i}-33.html")
    system("/usr/local/bin/ruby covid19.rb #{i} NO -en true> contents/sanpei3.github.io/covid19jp-#{i}-en.html")
    system("/usr/local/bin/ruby covid19.rb #{i} YES -en true > contents/sanpei3.github.io/covid19jp-#{i}-33-en.html")
    system("/usr/local/bin/ruby covid19.rb #{i} NO -ja false > contents/sanpei3.github.io/covid19jp-#{i}-nolog.html")
  }
  File.open(md5_filename, "w") do |io|
    io.write md5
  end
end