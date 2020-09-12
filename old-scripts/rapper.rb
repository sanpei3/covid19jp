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

md5_csse_global_filename = "confirmed_global.md5"
csv_csse_global_filename = "./CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"

md5_csse_us_filename = "confirmed_us.md5"
csv_csse_us_filename = "./CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"

md5_csse_us_state_filename = "time_series_covid19_confirmed_US_State.md5"
csv_csse_us_state_filename = "time_series_covid19_confirmed_US_State.csv"

md5_japan_filename = "time_series_covid19_confirmed_Japan.md5"
csv_japan_filename = "time_series_covid19_confirmed_Japan.csv"

md5_csse_global_old = ""
md5_csse_us_old = ""
md5_csse_us_state_old = ""
md5_japan_old = ""
create_md5_flag = nil
if (!File.exist?(md5_csse_global_filename))
  File.new(md5_csse_global_filename, "w")
  create_md5_flag = true
end
if (!File.exist?(md5_csse_us_filename))
  File.new(md5_csse_us_filename, "w")
  create_md5_flag = true
end
if (!File.exist?(md5_csse_us_state_filename))
  File.new(md5_csse_us_state_filename, "w")
  create_md5_flag = true
end
if (!File.exist?(md5_japan_filename))
  File.new(md5_japan_filename, "w")
  create_md5_flag = true
end
if (create_md5_flag == nil)
  sleep(rand(20))
end

File.open(md5_csse_global_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_csse_global_old = oneline
  end
end
File.open(md5_csse_us_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_csse_us_old = oneline
  end
end
File.open(md5_csse_us_state_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_csse_us_state_old = oneline
  end
end
File.open(md5_japan_filename,"r") do |mail|
  mail.each_line do |oneline|
    md5_japan_old = oneline
  end
end

# 変化があったか確認
#

csv = ""
File.open(csv_csse_global_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5_csse_global = Digest::MD5.new.update(csv).to_s

csv = ""
File.open(csv_csse_us_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5_csse_us = Digest::MD5.new.update(csv).to_s

csv = ""
File.open(csv_csse_us_state_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5_csse_us_state = Digest::MD5.new.update(csv).to_s

csv = ""
File.open(csv_japan_filename,"r") do |csv_file|
  csv_file.each_line do |oneline|
    csv = csv + oneline
  end
end
#
md5_japan = Digest::MD5.new.update(csv).to_s
##################################################
base_values = [150]
if (md5_japan_old != md5_japan)
  create_graph(base_values)
end

base_values = [150]
if (md5_japan_old != md5_japan || md5_csse_global_old != md5_csse_global)
  create_graph_ww(base_values)
end

if (md5_japan_old != md5_japan || md5_csse_us_old != md5_csse_us)
  system("/usr/local/bin/ruby daily-graph.rb > contents/sanpei3.github.io/covid19-daily.html")
end

if (md5_japan_old != md5_japan || md5_csse_us_state_old != md5_csse_us_state )
  create_graph_CSSE(base_values)
end
########################################################
#
# update md5 file
#
if (md5_japan_old != md5_japan)
  File.open(md5_japan_filename, "w") do |io|
    io.write md5_japan
  end
end

if (md5_csse_global_old != md5_csse_global)
  File.open(md5_csse_global_filename, "w") do |io|
    io.write md5_csse_global
  end
end

if (md5_csse_us_old != md5_csse_us)
  File.open(md5_csse_us_filename, "w") do |io|
    io.write md5_csse_us
  end
end

if (md5_csse_us_state_old != md5_csse_us_state)
  File.open(md5_csse_us_state_filename, "w") do |io|
    io.write md5_csse_us_state
  end
end
