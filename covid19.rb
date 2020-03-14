# coding: utf-8

#
# 1. read csv
# 2. 日毎、県ごとのを計算していく(base countまで入れておく)
# 3. base countを超えたときから、配列をずらしていく

require 'csv'

base_count = 20

#######################################################################
def mmddyyyy2date(str)
  if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    return Date.new($3.to_i, $1.to_i, $2.to_i)
  end
end
#######################################################################
#
# matrix{県名}[0]
# last_day{県名}
# last_index{県名}

last_day = {}
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
m.each{|a|
  print "#{a[0]},"
  a[1].each {|i|
    print "#{i},"
  }
  print "\n"
}
