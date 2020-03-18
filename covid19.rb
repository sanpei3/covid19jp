# coding: utf-8

#
# 1. read csv
# 2. 日毎、県ごとのを計算していく(base countまで入れておく)
# 3. base countを超えたときから、配列をずらしていく

require 'csv'

base_count = ARGV[0].to_i
add_33percent_graph = ARGV[1].to_s
#######################################################################
def mmddyyyy2date(str)
  if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    return Date.new($3.to_i, $1.to_i, $2.to_i)
  end
end

def readHtml(filename, replace)
  File.open(filename, "r:UTF-8") do |body|
    body.each_line do |oneline|
      replace.each do |str, replace|
        oneline = oneline.gsub(/#{str}/, replace)
      end
      puts oneline
    end
  end
end
 

#######################################################################
#
# matrix{県名}[0]
# last_day{県名}
# last_index{県名}

color_table = [ "Red", "Blue", "Green", "Black", "Cyan", "Orange", "Purple"]
max_color_index = color_table.length
color_index = 0


last_day = {}
max_x = 0
m = {}
last_index = {}
skip_header = true
CSV.foreach("COVID-19.csv") do |row|
  if (skip_header)
    skip_header = nil
    next
  end
#  pp row
  pref = row[9]
  day = row[7]
  status = row[15]
  if (status == "退院" || status =~ /^死亡/)
    next
  end
  #
  if (last_day[pref] == nil)
    # 新規
    last_day[pref] = day
    m[pref] = [1]
    last_index[pref] = 0
    ############################################
  elsif (last_day[pref] != day)
    # 新しい
    if (m[pref][0] >= base_count)
      # 基準以上になったらずらしていく
      # lastと引き算をする
      new_day = last_index[pref] + (mmddyyyy2date(day) - mmddyyyy2date(last_day[pref])).to_i
      if (nil && pref == "東京都")
        puts pref
        puts day
        puts new_day
      end
      i = last_index[pref]
      while (new_day > i)
        m[pref][i] = m[pref][last_index[pref]]
        i = i +1
      end
      m[pref][new_day] = m[pref][last_index[pref]] + 1   # 日数分ずらして
      last_index[pref] = new_day
      if (max_x < new_day)
        max_x = new_day
      end
      last_day[pref] = day
    else
      #
      m[pref][0] = m[pref][0] + 1
      last_day[pref] = day
    end
  else
    # 同じ日ならば、
    m[pref][last_index[pref]] = m[pref][last_index[pref]] + 1
  end
end
#pp m
pref = []
colors =[]
data = []
for i in 0..max_x do
  a = []
  a.push(i)
  data.push(a)
end

select_str = []
replace_base_count = ['%%base_count%%', base_count.to_s]
select_str.push(replace_base_count)
if (add_33percent_graph == "YES")
  # create 33% DAILY INCREASE
  select_str.push(["%%33%%", "-33"])
  select_str.push(["%%33-SELECT%%", "selected"])
  select_str.push(["%%33-NOT-SELECT%%", ""])
  pref.push("33% DAILY INCREASE")
  colors.push("LightGray")
  y = base_count
  for i in 0..max_x do
    data[i].push(y)
    data[i].push("''")
    data[i].push("false")
    y = y * 1.33
  end
else
    select_str.push(["%%33%%", ""])
    select_str.push(["%%33-SELECT%%", ""])
    select_str.push(["%%33-NOT-SELECT%%", "selected"])
end

m.each{|a|
  if (a[1][0] >= base_count)
    x = 0
    pref.push(a[0])
    colors.push(color_table[color_index % max_color_index])
    color_index = color_index + 1
    l = 0
    a[1].each {|i|
      data[x].push(i)
      data[x].push("''")
      data[x].push("true")
      x = x + 1
    }
    for i in x..max_x do
      data[x].push(base_count)
      data[x].push("'stroke-width: 0;'")
      data[x].push("true")
      x = x + 1
    end
  end
}

# グラフ作成
base_values = [1,10,20,30,40,50,60,70,80,90,100]
select_str.push(["%%UPDATE%%", Time.now.to_s])
base_values.each{|b|
  a = []
  a.push("%%#{b}%%")
  if (b == base_count)
    a.push("selected")
    select_str.push(a)
  else
    a.push("")
    select_str.push(a)
  end
}


readHtml("header.html", [replace_base_count])

puts "var pref =  #{pref};"

readHtml("mid.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail.html", [replace_base_count])

puts "colors: #{colors}"


readHtml("tail2.html", select_str)
