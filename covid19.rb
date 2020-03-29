# coding: utf-8

require 'csv'

base_count = ARGV[0].to_i
add_33percent_graph = ARGV[1].to_s
lang = ARGV[2].to_s
if (lang != "-en")
  lang = ""
end
yscale = ['%%yscale%%', ARGV[3].to_s]
#######################################################################
def mmddyyyy2date(str)
  if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    return Date.new($3.to_i, $1.to_i, $2.to_i)
  end
end

def date2mmdd(date)
  return date.strftime("%m/%d")
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

color_table = [ "Red", "Blue", "Green", "Black", "Cyan", "Orange", "Purple"]
max_color_index = color_table.length
color_index = 0

pref_en = {"北海道": "Hokkaido",
           "青森県": "Aomori",
           "岩手県": "Iwate",
           "宮城県": "Miyagi",
           "秋田県": "Akita",
           "山形県": "Yamagata",
           "福島県": "Fukushima",
           "茨城県": "Ibaraki",
           "栃木県": "Tochigi",
           "群馬県": "Gunma",
           "埼玉県": "Saitama",
           "千葉県": "Chiba",
           "東京都": "Tokyo",
           "神奈川県": "Kanagawa",
           "新潟県": "Niigata",
           "富山県": "Toyama",
           "石川県": "Ishikawa",
           "福井県": "Fukui",
           "山梨県": "Yamanashi",
           "長野県": "Nagano",
           "岐阜県": "Gifu",
           "静岡県": "Shizuoka",
           "愛知県": "Aichi",
           "三重県": "Mie",
           "滋賀県": "Shiga",
           "京都府": "Kyoto",
           "大阪府": "Osaka",
           "兵庫県": "Hyogo",
           "奈良県": "Nara",
           "和歌山県": "Wakayama",
           "鳥取県": "Tottori",
           "島根県": "Shimane",
           "岡山県": "Okayama",
           "広島県": "Hiroshima",
           "山口県": "Yamaguchi",
           "徳島県": "Tokushima",
           "香川県": "Kagawa",
           "愛媛県": "Ehime",
           "高知県": "Kochi",
           "福岡県": "Fukuoka",
           "佐賀県": "Saga",
           "長崎県": "Nagasaki",
           "熊本県": "Kumamoto",
           "大分県": "Oita",
           "宮崎県": "Miyazaki",
           "鹿児島県": "Kagoshima",
           "沖縄県": "Okinawa",
           "羽田空港": "Haneda Airport",
           "不明": "Unknown",
          }

last_day = {}
max_x = 0
max_y = 0
m = {}
last_index = {}
skip_header = true
CSV.foreach("COVID-19.csv", "r:UTF-8") do |row|
  if (skip_header)
    skip_header = nil
    next
  end
  pref = row[9]
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
###########################################################

if (base_count == 150 && add_33percent_graph == "YES")
  cssegis_header = []
  countries = ["US", "Italy", "Spain", "Korea, South", "United Kingdom"]
  countries.each{ |c|
    pref_en.store(:"#{c}", c)
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
            m[c][d_i] = [row[i].to_i, "#{d_i}:#{d}"]
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

#################################

m.each{|a|
  if (a[1][0][0] >= base_count)
    x = 0
    if (lang == "-en")
      pref.push(pref_en[:"#{a[0]}"])
    else
      pref.push(a[0])
    end
    colors.push(color_table[color_index % max_color_index])
    color_index = color_index + 1
    l = 0
    a[1].each {|i, d|
      data[x].push(i)
      data[x].push("''")
      data[x].push("true")
      if (lang == "-en")
        p = pref_en[:"#{a[0]}"]
      else
        p = a[0]
      end
      data[x].push("'#{d}\n#{p}:#{i}'")
      if ((a[0] == "United Kingdom" && d =~ /03\/23/)||
          (a[0] == "Italy" && d =~ /03\/11/)||
          (a[0] == "Spain" && d =~ /03\/13/)||
          (a[0] == "Korea, South" && d =~ /03\/22/))
        data[x].push("'Lockdown'")
      elsif (a[0] == "US" && d =~ /03\/22/)
        data[x].push("'NY:PAUSE'")
      elsif (a[0] == "US" && d =~ /03\/17/)
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
base_values = [1,10,20,30,40,50,60,70,80,90,100,150]
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

readHtml("header#{lang}.html", header_str)

puts "var pref =  #{pref};"

readHtml("mid.html", [])

data_str = "data.addRows(#{data});".gsub(/"/,"")
puts data_str

readHtml("tail#{lang}.html", tail_str)

puts "colors: #{colors}"


readHtml("tail2#{lang}.html", select_str)
