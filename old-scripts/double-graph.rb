# coding: utf-8

require 'csv'
require "./util"

start_date = "3/15/20"
$days = 6

max_color_index = $color_table.length
color_index = 0
# グラフフォーマットへ変換
# XX 海外の国や、US 州を出してみる

lang = "-ja"
if (lang != "-en")
  lang = ""
end
countres_flag = nil
states_flag =true
states = []
countries = []

if (states_flag)
  states_list = [
    "Minnesota",
#    "New York",
#    "California",
#    "Washington",
  ]
  states = {}
  states_list.each do |p|
    states[p] = true
  end
end
if (countres_flag)
  countries = ["US", "Italy", "Spain", "Korea, South", "United Kingdom", "India", "Serbia", "Germany", "Philippines", "Turkey", "Russia", "Austria", "Japan"]
end
prefecture_list = ["Tokyo",
               "Kanagawa",
               "Chiba",
               "Saitama",
               "Osaka",
               "Hyogo",
               "Fukuoka",
               "Aichi",
               "Hokkaido",
               "Ibaraki",
               "Okinawa",
               "Toyama",
               "Gunma",
               "Ishikawa",
                  ]
prefecture_list = [
  "Tokyo",
  "Kanagawa",
  "Hokkaido",
]
prefectures = {}
prefecture_list.each do |p|
  prefectures[p] = true
end

########################################

def calculate_double_days(row, i)
  if (row[i] == row[i - $days] || row[i - $days].to_i == 0)
    return Float::INFINITY
  else    
    double = (($days) * Math.log(2, 2) / Math.log(row[i].to_f / row[i - $days].to_f, 2))
    if (double == Float::INFINITY || double.nan?)
      return Float::INFINITY
    else
      digit = 100.0
      return ((double * digit).round)/digit
    end
  end
end

def mmddyy2ChartDate(str)
  if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    y = "20#{$3}"
    m = $1.to_i - 1
    d = $2.to_i
    return "new Date(#{y}, #{m}, #{d})"
  end
end


########################################
#
# 1. データ読み込む(time_series_covid19_confirmed_Japan.csv)で良いと思う。
m = {}
time_series_header = []
max_row = 0
max_x = 0
max_y = 0
start_i_j = 4

start_Date = Time.now
if (/(\d+)\/(\d\d)\/(\d\d)/ =~ start_date)
  start_Date = Date.new("20#{$3}".to_i, $1.to_i, $2.to_i)
end


if (states_flag)
  base_count = 1
  last_day = {}
  days = {}
  CSV.foreach("time_series_covid19_confirmed_US_State.csv", "r:UTF-8") do |row|
    if (time_series_header == [])
      time_series_header = row
      max_row = row.length
      # start_dateな rowを探す
      i = 4
      while (row[i] != start_date)
        i = i + 1
      end
      start_i_j = i
      next
    end
    pref = row[0]
    last_d = Float::INFINITY
    if ((states[pref] &&
         row[row.length - 1].to_i > 100) &&
        pref != "Narita Airport")
      #  puts pref
      i = start_i_j
      d_i = 0
      while ( i < max_row)
        d = calculate_double_days(row, i)
        if (d == Float::INFINITY && last_d != Float::INFINITY)
          d = last_d
        end
        #    puts d
        if (m[pref] == nil)
          m[pref] = [d, time_series_header[i]]
        else
          m[pref][d_i] = [d, time_series_header[i]]
        end
        last_d = d
        i = i + 1
        d_i = d_i + 1
        if (max_x <= d_i)
          max_x = d_i
        end
      end
    end
    # 探したところから、7日間の値を得る
  end
end


CSV.foreach("time_series_covid19_confirmed_Japan.csv", "r:UTF-8") do |row|
  if (time_series_header == [])
    time_series_header = row
    max_row = row.length
    # start_dateな rowを探す
    i = 4
    while (row[i] != start_date)
      i = i + 1
    end
    start_i_j = i
    next
  end
  pref = row[0]
  last_d = Float::INFINITY
#  if (prefectures[pref])
  if ((prefectures[pref] && row[row.length - 1].to_i > 100) &&
      pref != "Narita Airport")
    #  puts pref
    i = start_i_j
    d_i = 0
    while ( i < max_row)
      d = calculate_double_days(row, i)
      if (d == Float::INFINITY && last_d != Float::INFINITY)
        d = last_d
      end
      #    puts d
      if (m[pref] == nil)
        m[pref] = [d, time_series_header[i]]
      else
        m[pref][d_i] = [d, time_series_header[i]]
      end
      last_d = d
      i = i + 1
      d_i = d_i + 1
      if (max_x <= d_i)
        max_x = d_i
      end
    end
  end
  # 探したところから、7日間の値を得る
end

if (countres_flag)
  countries_hash = {}
  countries.each{ |c|
    countries_hash.store(:"#{c}", true)
  }
  start_i = 4
  time_series_header_global = []
  CSV.foreach("./CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", "r:UTF-8") do |row|
    if (time_series_header_global == [])
      time_series_header_global = row
      max_row = row.length
      # start_dateな rowを探す
      i = 4
      while (row[i] != start_date)
        i = i + 1
      end
      start_i = i
      next
    end
    pref = row[1]
    if (countries_hash[:"#{pref}"] && row[0].to_s == "")
      i = start_i
      d_i = 0
      while (i < max_row)
        d = calculate_double_days(row, i)
        if (m[pref] == nil)
          m[pref] = [d, time_series_header_global[i]]
        else
          m[pref][d_i] = [d, time_series_header_global[i]]
        end
        i = i + 1
        d_i = d_i + 1
        if (max_x <= d_i)
          max_x = d_i
        end
      end
    end
    # 探したところから、7日間の値を得る
  end
end  

pref = []
colors =[]
data = []
for i in 0..(max_x-1) do
  a = []
  d = 
    a.push(mmddyy2ChartDate(time_series_header[i+start_i_j]))
  data.push(a)
end

#pp m
#exit

m.each{|a|
  x = 0
  pref.push(prefen2prefjp(a[0], lang))
  if (a[0] == "Tokyo")
      colors.push("Red")
  else
    colors.push($color_table[color_index % max_color_index])
    color_index = color_index + 1
  end
  l = 0
  infinity_flag = nil
  a[1].each {|i, d|
    if (i == Float::INFINITY)
      data[x].push(100)
      data[x].push("'stroke-width: 0;'")
      data[x].push("true")
      data[x].push("''")
      data[x].push("null")
      infinity_flag = true
    else
      data[x].push(i)
      if (infinity_flag)
        data[x].push("'stroke-width: 0;'")
        infinity_flag = nil
      else
        data[x].push("''")
      end
      data[x].push("true")
      p = a[0]
      data[x].push("'#{d}\n#{p}:#{i}'")
      data[x].push("null")
    end
      x = x + 1
  }
  if (x <= max_x)
    for i in x..max_x-1 do
      data[x].push(1)
      data[x].push("'stroke-width: 0;'")
      data[x].push("true")
      data[x].push("''")
      data[x].push("null")
      x = x + 1
    end
  end
}

# グラフ作成
world_wide = ""
select_str = []
select_str.push(["%%UPDATE%%", Time.now.to_s])
days_str = ["%%DAYS%%", ($days + 1).to_s]
header_str = []
header_str.push(days_str)

tail_str = []
yscale = ['%%yscale%%', "true"]
tail_str.push(yscale)
tail_str.push(days_str)

readHtml("header-double#{lang}#{world_wide}.html", header_str)

puts "var pref =  #{pref};"

readHtml("mid-double.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail-double#{lang}#{world_wide}.html", tail_str)

puts "colors: #{colors}"


readHtml("tail2-double#{lang}#{world_wide}.html", select_str)

