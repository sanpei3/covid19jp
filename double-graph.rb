# coding: utf-8

require 'csv'
require "./util"

max_color_index = $color_table.length
color_index = 0
# グラフフォーマットへ変換
# XX 海外の国や、US 州を出してみる

lang = "-en"

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
max_y = 0

start_date = "3/23/20"
start_Date = Time.now
if (/(\d+)\/(\d\d)\/(\d\d)/ =~ start_date)
  start_Date = Date.new("20#{$3}".to_i, $1.to_i, $2.to_i)
end


states = [
  ["Minnesota", "US"],
  ["New York", "US"],
  ["California", "US"],
  ["Washington", "US"]
]
base_count = 1
last_day = {}
dir_name = "CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/"
Dir::foreach(dir_name) do |filename|
  if (filename =~ /\.csv$/)
    onedayData = {}
    date = ""
    CSV.foreach(dir_name + filename, "r:UTF-8") do |row|
      /(\d\d)-(\d\d)-(\d\d\d\d).csv/.match(filename)
      date = Date.new($3.to_i, $1.to_i, $2.to_i)
      if (date >= start_Date - 6)
        if (olderThan03212020(filename))
          state = row[0]
          country = row[1]
          confirmed = row[3].to_i
          if (confirmed.to_i >= base_count)
            states.each{|s, c|
              if (state == s && country == c)
                m_index = "#{s},#{c}"
                onedayData[m_index] = confirmed
              end
            }
          end
        else
          county = row[1]
          state = row[2]
          country = row[3]
          confirmed = row[7].to_i
          states.each{|s, c|
            if (state == s && country == c)
              m_index = "#{s},#{c}"
              # at first s, c だったら、テンポラリの合計に入れる
              if (onedayData[m_index]  == nil)
                onedayData[m_index]  = confirmed
              else
                onedayData[m_index]  = onedayData[m_index] + confirmed
              end
            end
          }
        end
      end
    end
    # after March/22 check whether add to m[] or not
    states.each{|s, c|
      m_index = "#{s},#{c}"
      d = date2mmdd(date)
      if (onedayData[m_index] != nil && onedayData[m_index] >= base_count)
        confirmed = onedayData[m_index]
        if (last_day[m_index] == nil)
          #puts s, c, confirmed, date.to_s
          last_day[m_index] = 0
          m[m_index] = []
        else
          last_day[m_index] = last_day[m_index] + 1
        end
        d_index = index2days(last_day[m_index] + 1, lang)
        #g = [confirmed, "#{d_index}:#{d}"]
        g = confirmed.to_i
        m[m_index][last_day[m_index]] = g
        if (max_x < last_day[m_index])
          max_x = last_day[m_index]
        end
        if (max_y < confirmed)
          max_y = confirmed
        end
      end
    }
  end
end
max_x = max_x - 6
m.each { |a|
  i = a[1].length - 1
  while (i >= 6)
    m[a[0]][i] = [calculate_double_days(a[1], i), ""]
    i = i - 1
  end
  while (i >= 0)
    m[a[0]].shift
    i = i - 1
  end
}


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

pref = []
colors =[]
data = []
for i in 0..(max_x-1) do
  a = []
  d = 
    a.push(mmddyy2ChartDate(time_series_header[i+start_i]))
  data.push(a)
end

#pp m
#exit

m.each{|a|
  x = 0
  pref.push(a[0])
  if (a[0] == "Tokyo")
      colors.push("Red")
  else
    colors.push($color_table[color_index % max_color_index])
    color_index = color_index + 1
  end
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

readHtml("header-double#{lang}#{world_wide}.html", [])

puts "var pref =  #{pref};"

readHtml("mid-double.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail-double#{lang}#{world_wide}.html", [])

puts "colors: #{colors}"


readHtml("tail2#{lang}#{world_wide}.html", select_str)

