# coding: utf-8
require 'digest/md5'
#########################################################
def create_graph(base_values)
  base_values.each{ |i|
    system("/usr/local/bin/ruby covid19.rb #{i} YES -ja true> contents/sanpei3.github.io/covid19jp-#{i}.html")
    system("/usr/local/bin/ruby covid19.rb #{i} YES -en true > contents/sanpei3.github.io/covid19jp-#{i}-en.html")
  }
end

def create_graph_ww(base_values)
  base_values.each{ |i|
    system("/usr/local/bin/ruby covid19.rb #{i} YES -ja true WW> contents/sanpei3.github.io/covid19jp-#{i}-WW-ja.html")
    system("/usr/local/bin/ruby covid19.rb #{i} YES -en true WW> contents/sanpei3.github.io/covid19jp-#{i}-WW-en.html")
  }
end

def create_graph_CSSE(base_values)
  base_values.each{ |i|
    system("/usr/local/bin/ruby CSSEGISandData.rb #{i} YES -ja true > contents/sanpei3.github.io/covid19jp-#{i}-US-ja.html")
    system("/usr/local/bin/ruby CSSEGISandData.rb #{i} YES -en true > contents/sanpei3.github.io/covid19jp-#{i}-US-en.html")
  }
end

source_url = "https://dl.dropboxusercontent.com/s/6mztoeb6xf78g5w/COVID-19.csv"
md5_filename = "COVID-19.md5"
csv_filename = "COVID-19.csv"
md5_csse_filename = "confirmed_global.md5"
csv_csse_filename = "./CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"


md5_old = ""
md5_csse_old = ""
create_md5_flag = nil
if (!File.exist?(md5_filename))
  File.new(md5_filename, "w")
  create_md5_flag = true
end
if (!File.exist?(md5_csse_filename))
  File.new(md5_csse_filename, "w")
  create_md5_flag = true
end
if (create_md5_flag == nil)
  sleep(rand(20))
end

File.open(md5_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_old = oneline
  end
end
File.open(md5_csse_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_csse_old = oneline
  end
end
#
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

csv = ""
File.open(csv_csse_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5_csse = Digest::MD5.new.update(csv).to_s
##################################################
base_values = [150]
if (md5_old != md5)
  create_graph(base_values)
  File.open(md5_filename, "w") do |io|
    io.write md5
  end
end

base_values = [150]

if (md5_old != md5 || md5_csse_old != md5_csse)
  create_graph_ww(base_values)
  create_graph_CSSE(base_values)
  system("/usr/local/bin/ruby daily-graph.rb > contents/sanpei3.github.io/covid19-daily.html")
  File.open(md5_filename, "w") do |io|
    io.write md5
  end
  File.open(md5_csse_filename, "w") do |io|
    io.write md5_csse
  end
end
