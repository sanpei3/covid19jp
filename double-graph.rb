# coding: utf-8

require 'csv'
require "./util"

max_color_index = $color_table.length
color_index = 0
# グラフフォーマットへ変換
# XX 海外の国や、US 州を出してみる


########################################

def calculate_double_days(row, i)
  d = 6
  double = (d * Math.log(2, 2) / Math.log(row[i].to_f / row[i - d].to_f, 2))
  if (double == Float::INFINITY)
    return 100
  else
    digit = 100.0
    return ((double * digit).round)/digit
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

prefectures = {"Tokyo" => true,
               "Kanagawa" => true,
               "Chiba" => true,
               "Saitama" => true,
               "Osaka" => true,
               "Hyogo" => true,
               "Fukuoka" => true,
               "Aichi" => true
              }

########################################
#
# 1. データ読み込む(time_series_covid19_confirmed_Japan.csv)で良いと思う。
m = {}
time_series_header = []
max_row = 0
max_x = 0
start_date = "3/23/20"
start_i = 4
CSV.foreach("time_series_covid19_confirmed_Japan.csv", "r:UTF-8") do |row|
  if (time_series_header == [])
    time_series_header = row
    max_row = row.length
    # start_dateな rowを探す
    i = 4
    while (row[i] != start_date)
      i = i + 1
    end
    start_i = i
    next
  end
  pref = row[0]
  if (prefectures[pref])
#  if (true)
    #  puts pref
    i = start_i
    d_i = 0
    while ( i < max_row)
      d = calculate_double_days(row, i)
      #    puts d
      if (m[pref] == nil)
        m[pref] = [d, time_series_header[i]]
      else
        m[pref][d_i] = [d, time_series_header[i]]
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
# 2. 最新の13日間 の7日ごとの感染者数が二倍になるまでの日数を求める
#    7日前と、その日の間の倍化日数を計算
#    2^x :  x =倍化日数
#    T= 6*log(2,2)/log(BU24/BO24,2)

pref = []
colors =[]
data = []
for i in 0..(max_x-1) do
  a = []
  d = 
  a.push(mmddyy2ChartDate(time_series_header[i+start_i]))
#  a.push(i)
  data.push(a)
end


m.each{|a|
  x = 0
  pref.push(a[0])
  colors.push($color_table[color_index % max_color_index])
  color_index = color_index + 1
  l = 0
  a[1].each {|i, d|
    data[x].push(i)
    data[x].push("''")
    data[x].push("true")
    p = a[0]
    data[x].push("'#{d}\n#{p}:#{i}'")
    data[x].push("null")
      x = x + 1
  }
}

# グラフ作成
lang = "-en"
world_wide = ""
select_str = []
select_str.push(["%%UPDATE%%", Time.now.to_s])

readHtml("header-double#{lang}#{world_wide}.html", [])

puts "var pref =  #{pref};"

readHtml("mid-double.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail-double#{lang}#{world_wide}.html", [])

puts "colors: #{colors}"


readHtml("tail2#{lang}#{world_wide}.html", select_str)

