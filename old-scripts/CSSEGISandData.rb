# coding: utf-8

require 'csv'
require "./util"

base_count = ARGV[0].to_i
lang = "-en"
if (lang != "-en")
  lang = ""
end

dir_name = "CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/"


states = [
  ["Minnesota", "US"],
  ["New York", "US"],
  ["California", "US"],
  ["Washington", "US"]
]
states.each{ |c, s|
  $pref_en.store(:"#{c},#{s}", "#{c},#{s}")
}

# not used
counties = [
  ["Rice", "Minnesota", "US"],
  ["San Francisco", "California", "US"]
]

################################

m = {}
last_day = {}
max_x = 0
max_y = 0
time_series_header = []
start_i_j = 11
max_row = 1
CSV.foreach("time_series_covid19_confirmed_US_State.csv", "r:UTF-8") do |row|
  if (time_series_header == [])
    time_series_header =row
    max_row = row.length
  end
  pref = row[0]
  states.each{|s, c|
    if (pref == s)
      i = 4
      d_i = 0
      while (i <= max_row)
        if (row[i].to_i >= base_count)
          if (m[pref] == nil)
            m[pref] = []
          end
          d = date2mmdd(mmddyyyy2date(time_series_header[i]))
          d_index = index2days(d_i, lang)
          m[pref][d_i] = [row[i].to_i, "#{d_index}:#{time_series_header[i]}"]
          d_i = d_i + 1
          if (max_y < row[i].to_i)
            max_y = row[i].to_i
          end
        end
        i = i + 1
      end
      if (max_x < d_i)
        max_x = d_i
      end
    end
  }
end

#############################################
time_series_header = []
max_row = 0
CSV.foreach("time_series_covid19_confirmed_Japan.csv", "r:UTF-8") do |row|
  if (time_series_header == [])
    time_series_header =row
    max_row = row.length
  end
  pref = row[0]
  i = 4
  d_i = 0
  while (i <= max_row)
    if (row[i].to_i >= base_count)
      if (m[pref] == nil)
        m[pref] = []
      end
      d = date2mmdd(mmddyyyy2date(time_series_header[i]))
      d_index = index2days(d_i, lang)
      m[pref][d_i] = [row[i].to_i, "#{d_index}:#{time_series_header[i]}"]
      d_i = d_i + 1
      if (max_y < row[i].to_i)
        max_y = row[i].to_i
      end
    end
    i = i + 1
  end
  if (max_x < d_i)
    max_x = d_i
  end
end
##########################################################
# 3. グラフへ
data = []
for i in 0..max_x do
  a = []
  a.push(i)
  data.push(a)
end

max_color_index = $color_table.length
color_index = 0

pref = []
colors =[]

select_str = []
header_str = []
add_33percent_suffix = ["%%33%%", "-33"]
add_33percent_graph = "YES"
if (add_33percent_graph == "YES")
  # create 33% DAILY INCREASE
  header_str.push(add_33percent_suffix)
  select_str.push(add_33percent_suffix)
  select_str.push(["%%33-SELECT%%", "selected"])
  select_str.push(["%%33-NOT-SELECT%%", ""])

  title = [["CASES DOUBLE EVERY DAY", "毎日2倍", 2],
           ["_EVERY 2DAYS", "2日で2倍", 1.41421356237309504880],
           ["_EVERY 3DAYS", "3日で2倍", 1.2599210498],
           ["_EVERY WEEK",  "一週間で2倍", 1.1040895136738]]
  title.each{ |t_en, t_ja, c|
    t = ""
    if (lang == "-en")
      t = t_en
    else
      t = t_ja
    end
    pref.push(t)
    colors.push("LightGray")
    y = base_count
    for i in 0..max_x do
      yy = y.round
      d_index = index2days(i, lang)
      tooltip = "'#{d_index}\n#{t}, #{yy}'"
      if (y < max_y)
        data[i].push(yy)
        data[i].push("''")
        data[i].push("false")
        d_index = index2days(i, lang)
        data[i].push(tooltip)
        data[i].push("null")
        y = y * c
      else
        data[i].push(y.round)
        data[i].push("'stroke-width: 0;'")
        data[i].push("true")
        data[i].push("' '")
        data[i].push("null")
      end
    end
  }
else
  select_str.push(remove_33percent_suffix)
  select_str.push(["%%33-SELECT%%", ""])
  select_str.push(["%%33-NOT-SELECT%%", "selected"])
end


m.each{|a|
  if (a[1][0][0] >= base_count)
    x = 0
    pref.push(prefJa2prefEn(a[0], lang))
    if (a[0] == "東京都")
      colors.push("Red")
    else
      colors.push($color_table[color_index % max_color_index])
      color_index = color_index + 1
    end
    l = 0
    a[1].each {|i, d|
      p = prefJa2prefEn(a[0], lang)
      if (i == 0)
        data[x].push(base_count)
        data[x].push("'stroke-width: 0;'")
        data[x].push("true")
        data[x].push("'#{d}\n#{p}:#{i}'")
        data[x].push("null")
      else
        data[x].push(i)
        data[x].push("''")
        data[x].push("true")
        data[x].push("'#{d}\n#{p}:#{i}'")
        if (p == "New York" && d =~ /3\/22\/20/)
          data[x].push("'PAUSE'")
        elsif (p == "California" && d =~ /3\/17\/20/)
          data[x].push("'Bay Area:shelter in place'")
        elsif (p == "California" && d =~ /3\/19\/20/)
          data[x].push("'California:shelter in place'")
        elsif (p == "Minnesota" && d =~ /3\/27\/20/)
          data[x].push("'Stay home'")
          #data[x].push("'Stay home except for essential needs'")
        elsif (p == "Washington" && d =~ /3\/23\/20/)
          data[x].push("'Stay home, Stay Healthy'")
        elsif (p == "Tokyo" && d =~ /XX03\/28/)
          data[x].push("'stay at home'")
          #data[x].push("'stay at home and refrain from going outside'")
        else
          data[x].push("null")
        end
      end
      x = x + 1
    }
    for i in x..max_x do
      data[x].push(base_count)
      data[x].push("'stroke-width: 0;'")
      data[x].push("true")
      data[x].push("''")
      data[x].push("null")
      x = x + 1
    end
  end
}

replace_base_count = ['%%base_count%%', base_count.to_s]

header_str = []
header_str.push(replace_base_count)
select_str = []
select_str.push(["%%UPDATE%%", Time.now.to_s])
tail_str = []
tail_str.push(replace_base_count)
yscale = ['%%yscale%%', "true"]
tail_str.push(yscale)
readHtml("header-CSSEGIS.html", header_str)


puts "var pref =  #{pref};"

readHtml("mid.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail-CSSEGIS.html", tail_str)

puts "colors: #{colors}"


readHtml("tail2-CSSEGIS.html", select_str)
