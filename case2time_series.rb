# coding: utf-8
#
require 'csv'
require "./util"

# 1. 読み込んで
# 2. 都道府県ごとに出していく

# XX最初の全体の症例が見つかった日で、すべての都道府県データをリセットする必要がある。

last_day = {}
max_day = 0
m = {}
last_index = {}
first_day = 0
skip_header = true
CSV.foreach("COVID-19.csv", "r:UTF-8") do |row|
  if (skip_header)
    skip_header = nil
    next
  end
  pref = row[9]
  day = row[7]
  if (day == nil || row[0] == nil)
    next
  end
  dDate = mmddyyyy2date(day)
  d = date2mmddyy(mmddyyyy2date(day))
  status = row[15]
  status2 = row[16]
  new_day = 0
  if (status2 =~ /帰国/)
    next
  end
  if (status == "退院" || status =~ /^死亡/)
    next
  end

  # 初めての入力か?
  if (last_day[pref] == nil)
    # 初めての入力かどうかを判断して、その情報を追加
    if (first_day == 0)
      first_day = dDate
      new_day = 0
    end
    last_index[pref] = 0
    # // 初日が全体の初日からずている場合には、0 を必要個入れる必要がある。
    if (first_day != dDate)
      i = dDate - first_day
      last_index[pref] = i
      m[pref] = [0]
      i = i - 1
      while (i != 0)
        m[pref].push(0)
        i = i - 1
      end
      m[pref].push(1)
    else
      # 本当の初めての登録
      m[pref] = [1]
      last_index[pref] = 0
    end
    last_day[pref] = day
    if (max_day < new_day)
      max_day = new_day
    end
    ############################################
  elsif (last_day[pref] != day)
    new_day = last_index[pref] + (mmddyyyy2date(day) - mmddyyyy2date(last_day[pref])).to_i
    i = last_index[pref]
    di = mmddyyyy2date(last_day[pref])
    while (new_day > i)
      m[pref][i] = m[pref][last_index[pref]]
      i = i +1
      di = di + 1
    end
    m[pref][new_day] = m[pref][last_index[pref]] + 1
    last_index[pref] = new_day
    if (max_day < new_day)
      max_day = new_day
    end
    last_day[pref] = day
  else
    # 同じ日ならば、
    m[pref][last_index[pref]] =m[pref][last_index[pref]] + 1
  end
end

# 末尾の0がないところ対策も必要。どうやる?? 個別?? 全体舐めるとき?
# 出力するとき?

CSV.open('time_series_covid19_confirmed_Japan.csv','w') do |csv| # output to csv file
  o = []
  o.push("Province/State")
  o.push("Country/Region")
  o.push("Lat")
  o.push("Long")
  d = first_day
  i = 0
  while ( i <= max_day)
    o.push(date2mmddyy(d))
    d = d + 1
    i = i + 1
  end
  csv << o
  m.each do |bo|
    pref = prefJa2prefEn(bo[0], "-en")

    while (bo[1].length <= max_day)
      bo[1].push(bo[1][bo[1].length - 1])
    end
    o = []
    o.push(pref)
    o.push("Japan")
    latlong = pref2latlong(pref)
    o.push(latlong[0])
    o.push(latlong[1])
    bo[1].each do |i|
      o.push(i)
    end
    csv << o
  end
end

# 都道府県名は英語化
# 

