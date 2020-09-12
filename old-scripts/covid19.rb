# coding: utf-8

require 'csv'
require "./util"

base_count = ARGV[0].to_i
add_33percent_graph = ARGV[1].to_s
lang = ARGV[2].to_s
if (lang != "-en")
  lang = ""
end
yscale = ['%%yscale%%', ARGV[3].to_s]

world_wide = ARGV[4].to_s
if (world_wide == "WW")
  world_wide = "-ww"
else
  world_wide = ""
end
#######################################################################

max_color_index = $color_table.length
color_index = 0


last_day = {}
max_x = 0
max_y = 0
m = {}
last_index = {}
skip_header = true

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
      m[pref][d_i] = [row[i].to_i, "#{d_index}:#{pref}"]
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

###########################################################

if (world_wide == "-ww" && add_33percent_graph == "YES")
  cssegis_header = []
  countries = ["US", "Italy", "Spain", "Korea, South", "United Kingdom", "India", "Serbia", "Germany", "Philippines", "Russia", "Brazil", "Japan"]
  countries.each{ |c|
    $pref_en.store(:"#{c}", c)
  }
  max_row = 0
  CSV.foreach("./CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", "r:UTF-8") do |row|
    if (cssegis_header == [])
      cssegis_header =row
      max_row = row.length
    end
    country = row[1]
    i = 4
    d_i = 0
    countries.each{ |c|
      if(country == c && row[0] == nil)
        m[c] = []
        while (i <= max_row)
          if (row[i].to_i >= base_count)
            d = date2mmdd(mmddyyyy2date(cssegis_header[i]))
            d_index = index2days(d_i, lang)
            m[c][d_i] = [row[i].to_i, "#{d_index}:#{d}"]
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
end

###########################################################
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
add_33percent_suffix = ["%%33%%", "-33"]
remove_33percent_suffix = ["%%33%%", ""]
header_str = []
header_str.push(replace_base_count)
tail_str = []
tail_str.push(replace_base_count)
tail_str.push(yscale)
select_str.push(replace_base_count)
if (base_count != 150)
  max_y = 7000
end
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
  header_str.push(remove_33percent_suffix)
  select_str.push(remove_33percent_suffix)
  select_str.push(["%%33-SELECT%%", ""])
  select_str.push(["%%33-NOT-SELECT%%", "selected"])
end

#################################

m.each{|a|
  if (a[1][0][0] >= base_count)
    x = 0
    pref.push(prefJa2prefEn(a[0], lang))
    if (a[0] == "東京最大予測" || a[0] == "東京平均予測")
      colors.push("LightPink")
    elsif (a[0] == "東京都")
      colors.push("Red")
    else
      colors.push($color_table[color_index % max_color_index])
      color_index = color_index + 1
    end
    l = 0
    a[1].each {|i, d|
      data[x].push(i)
      data[x].push("''")
      if (a[0] == "東京最大予測" || a[0] == "東京平均予測")
        data[x].push("true")
      else
        data[x].push("true")
      end
      p = prefJa2prefEn(a[0], lang)
      data[x].push("'#{d}\n#{p}:#{i}'")
      if ((a[0] == "United Kingdom" && d =~ /XX03\/23/)||
          (a[0] == "Italy" && d =~ /XX03\/11/)||
          (a[0] == "Spain" && d =~ /XX03\/13/)||
          (a[0] == "Korea, South" && d =~ /XX03\/22/))
        data[x].push("'Lockdown'")
      elsif (a[0] == "US" && d =~ /XX03\/22/)
        data[x].push("'NY:PAUSE'")
      elsif (a[0] == "US" && d =~ /XX03\/17/)
        data[x].push("'Bay Area:shelterInPlace'")
      else
        data[x].push("null")
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

# グラフ作成
if (world_wide == "-ww")
  base_values = [100,150]
else
  base_values = [1,10,20,30,40,50,60,70,80,90,100,150]
end
select_str.push(["%%UPDATE%%", Time.now.to_s])
select_str.push(add_33percent_suffix)
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

readHtml("header#{lang}#{world_wide}.html", header_str)

puts "var pref =  #{pref};"

readHtml("mid.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail#{lang}#{world_wide}.html", tail_str)

puts "colors: #{colors}"


readHtml("tail2#{lang}#{world_wide}.html", select_str)
