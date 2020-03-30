# coding: utf-8

require 'csv'
require "./util"

base_count = 150
lang = "-en"
if (lang != "-en")
  lang = ""
end

dir_name = "CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/"


states = [
  ["Minnesota", "US"],
  ["New York", "US"],
  ["California", "US"]
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

def olderThan03212020 (filename)
  if (filename =~ /0[12]-\d\d-2020.csv/ ||
      filename =~ /03-[01]\d-2020.csv/ ||
      filename =~ /03-2[01]-2020.csv/)
    return true
  else
    return false
  end
end


m = {}
last_day = {}
max_x = 0
max_y = 0
Dir::foreach(dir_name) do |filename|
  if (filename =~ /\.csv$/)
    onedayData = {}
    date = ""
    CSV.foreach(dir_name + filename, "r:UTF-8") do |row|
      # for old style (before March-21-2020)
      /(\d\d)-(\d\d)-(\d\d\d\d).csv/.match(filename)
      date = Date.new($3.to_i, $1.to_i, $2.to_i)
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
        d_index = last_day[m_index] + 1
        g = [confirmed, "#{d_index}:#{d}"]
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
#############################################
last_index = {}
skip_header = true
CSV.foreach("COVID-19.csv", "r:UTF-8") do |row|
  if (skip_header)
    skip_header = nil
    next
  end
  pref = row[9]
  if (row[7] == nil)
    next
  end
  day = row[7]
  d = date2mmdd(mmddyyyy2date(day))
  status = row[15]
  status2 = row[16]
  if (status2 =~ /帰国/)
    next
  end
  if (status == "退院" || status =~ /^死亡/)
    next
  end
  if (last_day[pref] == nil)
    # 新規
    last_day[pref] = day
    m[pref] = [[1, "1:#{d}"]]
    if (max_y < 1)
      max_y = 1
    end
    last_index[pref] = 0
    ############################################
  elsif (last_day[pref] != day)
    # 新しい
    if (m[pref][0][0] >= base_count)
      # 基準以上になったらずらしていく
      # lastと引き算をする
      new_day = last_index[pref] + (mmddyyyy2date(day) - mmddyyyy2date(last_day[pref])).to_i
      i = last_index[pref]
      di = mmddyyyy2date(last_day[pref])
      while (new_day > i)
        m[pref][i] = [m[pref][last_index[pref]][0], "#{i}:#{date2mmdd(di)}"]
        i = i +1
        di = di + 1
      end
      m[pref][new_day] = [m[pref][last_index[pref]][0] + 1, "#{i}:#{d}"]   # 日数分ずらして
      if (max_y < m[pref][last_index[pref]][0] + 1)
        max_y = m[pref][last_index[pref]][0] + 1
      end
      last_index[pref] = new_day
      if (max_x < new_day)
        max_x = new_day
      end
      last_day[pref] = day
    else
      m[pref][0] = [m[pref][0][0] + 1, "1:#{d}"]
      if (max_y < m[pref][0][0] + 1)
        max_y = m[pref][0][0] + 1
      end
      last_day[pref] = day
    end
  else
    # 同じ日ならば、
    m[pref][last_index[pref]] =
      [m[pref][last_index[pref]][0] + 1,
       "#{last_index[pref]}:#{d}"]
    if (max_y < m[pref][last_index[pref]][0] + 1)
      max_y = m[pref][last_index[pref]][0] + 1
    end
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

color_table = [ "Red", "Blue", "Green", "Black", "Cyan", "Orange", "Purple"]
max_color_index = color_table.length
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
  if (lang == "-en")
    pref.push("CASES DOUBLE EVERY DAY")
  else
    pref.push("毎日2倍")
  end
  colors.push("LightGray")
  y = base_count
  for i in 0..max_x do
    if (y < max_y)
      data[i].push(y.round)
      data[i].push("''")
      data[i].push("false")
      data[i].push("''")
      data[i].push("null")
      y = y * 2
    else
      data[i].push(y.round)
      data[i].push("'stroke-width: 0;'")
      data[i].push("true")
      data[i].push("''")
      if (i == max_x)
        data[i].push("null")
      else
        data[i].push("null")
      end
    end
  end
  if (lang == "-en")
    pref.push("_EVERY 2DAYS")
  else
    pref.push("2日で2倍")
  end
  colors.push("LightGray")
  y = base_count
  for i in 0..max_x do
    if (y < max_y)
      data[i].push(y.round)
      data[i].push("''")
      data[i].push("false")
      data[i].push("''")
      data[i].push("null")
      y = y * 1.41421356237309504880
    else
      data[i].push(y.round)
      data[i].push("'stroke-width: 0;'")
      data[i].push("true")
      data[i].push("''")
      if (i == max_x)
        data[i].push("null")
      else
        data[i].push("null")
      end
    end
  end
  if (lang == "-en")
    pref.push("_EVERY 3DAYS")
  else
    pref.push("3日で2倍")
  end
  colors.push("LightGray")
  y = base_count
  for i in 0..max_x do
    if (y < max_y)
      data[i].push(y.round)
      data[i].push("''")
      data[i].push("false")
      data[i].push("''")
      if (i == max_x)
        data[i].push("null")
      else
        data[i].push("null")
      end
      y = y * 1.2599210498
    else
      data[i].push(y.round)
      data[i].push("'stroke-width: 0;'")
      data[i].push("true")
      data[i].push("''")
      if (i == max_x)
        data[i].push("null")
      else
        data[i].push("null")
      end
    end
  end
  if (lang == "-en")
    pref.push("_EVERY WEEK")
  else
    pref.push("一週間で2倍")
  end
  colors.push("LightGray")
  y = base_count
  for i in 0..max_x do
    data[i].push(y.round)
    data[i].push("''")
    data[i].push("false")
    data[i].push("''")
    if (i == max_x)
      data[i].push("null")
    else
      data[i].push("null")
    end
    y = y * 1.1040895136738
  end
else
  header_str.push(remove_33percent_suffix)
  select_str.push(remove_33percent_suffix)
  select_str.push(["%%33-SELECT%%", ""])
  select_str.push(["%%33-NOT-SELECT%%", "selected"])
end


m.each{|a|
  if (a[1][0][0] >= base_count)
    x = 0
    if (lang == "-en")
      pref.push($pref_en[:"#{a[0]}"])
    else
      pref.push(a[0])
    end
    colors.push(color_table[color_index % max_color_index])
    color_index = color_index + 1
    l = 0
    a[1].each {|i, d|
      if (lang == "-en")
        p = $pref_en[:"#{a[0]}"]
      else
        p = a[0]
      end
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
        if (p == "New York,US" && d =~ /03\/22/)
          data[x].push("'PAUSE'")
        elsif (p == "California,US" && d =~ /03\/17/)
          data[x].push("'Bay Area:shelter in place'")
        elsif (p == "California,US" && d =~ /03\/19/)
          data[x].push("'California:shelter in place'")
        elsif (p == "Minnesota,US" && d =~ /03\/27/)
          data[x].push("'Stay home'")
          #data[x].push("'Stay home except for essential needs'")
        elsif (p == "Tokyo" && d =~ /03\/28/)
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
