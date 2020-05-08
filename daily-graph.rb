# coding: utf-8

require 'csv'
require "./util"
#
#
states_flag =true
states = []
if (states_flag)
  states = [
    ["Minnesota", "US"],
    ["New York", "US"],
    ["California", "US"],
    ["Washington", "US"]
  ]
end
prefecture_list = [
  "Tokyo",
  "Kanagawa",
]
prefectures = {}
prefecture_list.each do |p|
  prefectures[p] = true
end
#

########################################
# XX X軸を作ってみる

start_mmdd = "3/22"
start_yy = "20"

i = mmddyyyy2date("#{start_mmdd}/20#{start_yy}")
start_date = "#{start_mmdd}/#{start_yy}"


now_time = Time.now
now = ""
if (/^(\d+)-(\d+)-(\d+)/ =~ now_time.to_s)
  now = Date.new($1.to_i, $2.to_i, $3.to_i)
end
labels = []
while (i < now)
  labels.push(date2mmdd(i))
  i = i + 1
end

m = {}
max_row = 0
max_x = 0
max_y = 0
######################################################################
if (states_flag)
  start_Date = Time.now
if (/(\d+)\/(\d+)\/(\d\d)/ =~ start_date)
  start_Date = Date.new("20#{$3}".to_i, $1.to_i, $2.to_i)
end
  base_count = 1
  last_day = {}
  days = {}
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
                  m_index = "#{s}"
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
                m_index = "#{s}"
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
        m_index = "#{s}"
        d = date2mmdd(date)
        if (onedayData[m_index] != nil && onedayData[m_index] >= base_count)
          confirmed = onedayData[m_index]
          if (last_day[m_index] == nil)
            last_day[m_index] = 0
            m[m_index] = []
          else
            last_day[m_index] = last_day[m_index] + 1
          end
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
  m_avg = {}
  m.each { |a|
    i = a[1].length - 1
    s_avg =  "#{a[0]}_avg"
    m_avg[s_avg] = [0]
    while (i >= 1)
      if (i > 6)
        m_avg[s_avg][i] = (a[1][i] - a[1][i - 6]) / 7
      else
        m_avg[s_avg][i] = 0
      end
      m[a[0]][i] = a[1][i] - a[1][i - 1]
      if (m[a[0]][i] < 0)
        m[a[0]][i] = 0
      end
      i = i - 1
    end
  }
  m_avg.each { |a|
    m[a[0]] = a[1]
  }
end

######################################################################

time_series_header = []
start_i_j = 4
# XX Tokyo, Kanagawa daily new cases>
CSV.foreach("time_series_covid19_confirmed_Japan.csv", "r:UTF-8") do |row|
  if (time_series_header == [])
    time_series_header = row
    max_row = row.length
    # start_dateな rowを探す
    i = 4
    while (row[i] != start_date)
      i = i + 1
    end
    start_i_j = i
    next
  end
  pref = row[0]
  pref_avg = "#{pref}_avg"
  last_d = Float::INFINITY
  if ((prefectures[pref]) &&
      pref != "Narita Airport")
    i = start_i_j
    d_i = 0
    d_avg = 0
    while ( i < max_row)
      d = row[i].to_i - row[i - 1].to_i
      if (i - start_i_j >= 6)
        d_avg = (row[i].to_i - row[i -6].to_i) / 7
      end
      if (d == Float::INFINITY && last_d != Float::INFINITY)
        d = last_d
      end
      #    puts d
      if (m[pref] == nil)
        m[pref] = [d]
        m[pref_avg] = [d_avg]
      else
        m[pref][d_i] = d
        m[pref_avg][d_i] = d_avg
      end
      last_d = d
      i = i + 1
      d_i = d_i + 1
      if (max_x <= d_i)
        max_x = d_i
      end
    end
  end
end


######################################################################
# XX 7 days avg.
     # --> by line

# XX, minnesota daily newcases
header_str = []
readHtml("daily-header.html", header_str)

m.each{|a|
  pref = a[0]
  if (pref !~ /_avg/)
    button = <<-EOS
	<button id="addDataset%%PREF%%">Add Dataset %%PREF_LONG%%</button>
	<button id="removeDataset%%PREF%%">Remove Dataset %%PREF_LONG%%</button>
EOS
    button = button.gsub(/%%PREF%%/, pref.gsub(/ /,""))
    button = button.gsub(/%%PREF_LONG%%/, pref)
    puts button
  end
}

mid_str = []
readHtml("daily-mid.html", mid_str)
pp labels
mid_str = []
readHtml("daily-mid2.html", mid_str)

color_table_daily = [ "Red", 
                      "Blue",
                      "Green", 
                      "Orange",
                      "Yellow",
                      "purple",
                      "grey",
                    ]

#  "Green", "Black", #"Cyan",
#  "Orange", "Purple",
#  "maroon", "olive", "fuchsia", #"aqua",
#  , "teal", "lime"
#  "navy", "silver", "gray"]

  
max_color_index = color_table_daily.length
color_index = 0
buttons = ""
pref_color = {}
m.each{|a|
  pref = a[0].gsub(/ /,"")
  pref_long = a[0]
  pref_short = pref.gsub(/_avg/,"")
  if (pref_color[pref_short] == nil)
    color = color_table_daily[color_index % max_color_index].downcase
    color_index = color_index + 1
    pref_color[pref_short] = color
  else
    color = pref_color[pref_short]
  end
  
  puts "var data#{pref} = "
  puts "{label: '#{pref_long}',"
  if (pref =~ /_avg/)
    puts "type: 'line',"
    puts "fill: false,"
    puts "borderColor: window.chartColors.#{color},"
  else
    puts "backgroundColor: color(window.chartColors.#{color}).alpha(0.5).rgbString(),"
    puts "borderColor: window.chartColors.#{color},"
    puts "borderWidth: 1,"
  end
  puts "data:  "
  pp a[1]
  puts ","
  puts "			}; "
  if (pref !~ /^NewYork/ && pref !~ /Washington/ && pref !~ /California/)
    puts "barChartData.datasets.push(data#{pref});"
  end

  if (pref !~ /_avg/)
    if (pref !~ /^NewYork/)
      puts "var datasetFlag#{pref} = true;"
    else
      puts "var datasetFlag#{pref} = false;"
    end
  button =  <<-EOS
		document.getElementById('addDataset%%PREF%%').addEventListener('click', function() {
		if (datasetFlag%%PREF%% == false) {
			barChartData.datasets.push(data%%PREF%%_avg);
			barChartData.datasets.push(data%%PREF%%);
			datasetFlag%%PREF%% = true;
			window.myBar.update();
			}
		});

		document.getElementById('removeDataset%%PREF%%').addEventListener('click', function() {
                    if (datasetFlag%%PREF%% == true) {
                        var l = barChartData.datasets.length;
                        console.log(l);
                        for (let i = 0; i < l ; i++) {
                            console.log(i);
                            console.log(barChartData.datasets[i].label);
                            if (barChartData.datasets[i].label == "%%PREF_LONG%%") {
                                barChartData.datasets.splice(i,1);
                                break;
                            }
                        }
                        var l = barChartData.datasets.length;
                        console.log(l);
                        for (let i = 0; i < l ; i++) {
                            if (barChartData.datasets[i].label == "%%PREF_LONG%%_avg") 
{
                                barChartData.datasets.splice(i,1);
                                break;
                            }
                        }
         		datasetFlag%%PREF%% = false;
                        window.myBar.update();
		    }
		});
EOS
  button = button.gsub(/%%PREF%%/, pref.gsub(/ /,""))
  button = button.gsub(/%%PREF_LONG%%/, pref_long)
  buttons = buttons + button
  end
}

tail_str = []
readHtml("daily-tail.html", tail_str)
puts buttons
tail2_str = []
readHtml("daily-tail2.html", tail2_str)
