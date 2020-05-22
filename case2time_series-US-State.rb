# coding: utf-8
#
require 'csv'
require "./util"

m = {}
first_day = ""
last_day = {}
max_x = 0
max_y = 0
time_series_header = []
start_i_j = 11
max_row = 1
CSV.foreach("CSSEGISandData/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv", "r:UTF-8") do |row|
    if (time_series_header == [])
      time_series_header = row
      max_row = row.length
      # start_dateな rowを探す
      i = 11
      first_day = row[i]
      start_i_j = i
      next
    end
    county = row[5]
    state = row[6]
    s = "#{state}"
    s_avg = "#{s}_avg"
    last_d = Float::INFINITY
    i = start_i_j
    d_i = 0
    while ( i < max_row)
      d = row[i].to_i
      if (d < 0)
        d = 0
      end
      if (m[state] == nil)
        m[state] = [d]
      else
        if (m[state][d_i] == nil)
          m[state][d_i] = d
        else
          m[state][d_i] = m[state][d_i] + d
        end
      end
      last_d = d
      i = i + 1
      d_i = d_i + 1
      if (max_x <= d_i)
        max_x = d_i
      end
    end
end

def mmddyy2date(str)
  if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    return Date.new($3.to_i, $1.to_i, $2.to_i)
  end
end

first_day = mmddyy2date(first_day)
max_day = max_row - start_i_j - 1

CSV.open('time_series_covid19_confirmed_US_State.csv','w') do |csv| # output to csv file
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
    state = bo[0]

    while (bo[1].length <= max_day)
      bo[1].push(bo[1][bo[1].length - 1])
    end
    o = []
    o.push(state)
    o.push("US")
    latlong = state
    o.push(0)
    o.push(0)
    bo[1].each do |i|
      o.push(i)
    end
    csv << o
  end
end
