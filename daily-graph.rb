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

start_mmdd = "3/1"
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


time_series_header = []
m = {}
start_i_j = 4
max_row = 0
max_x = 0
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



# XX 7 days avg.
     # --> by line

# XX, minnesota daily newcases
header_str = []
readHtml("daily-header.html", header_str)

pp labels
mid_str = []
readHtml("daily-mid.html", mid_str)

color_table_daily = [ "Red", "Red",
                      "Blue", "Blue",
                    "Green", "Green"]

#  "Green", "Black", #"Cyan",
#  "Orange", "Purple",
#  "maroon", "olive", "fuchsia", #"aqua",
#  , "teal", "lime"
#  "navy", "silver", "gray"]

  
max_color_index = $color_table.length
color_index = 0
buttons = ""
m.each{|a|
  pref = a[0]
  color = color_table_daily[color_index % max_color_index].downcase
  
  color_index = color_index + 1
  puts "var data#{pref} = "
  puts "{label: '#{pref}',"
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
  puts "barChartData.datasets.push(data#{pref});"
  puts "var datasetFlag#{pref} = true;"

  if (pref !~ /_avg/)
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
			barChartData.datasets.pop(data%%PREF%%_avg);
			barChartData.datasets.pop(data%%PREF%%);
			datasetFlag%%PREF%% = false;
			window.myBar.update();
			}
		});
EOS
  button = button.gsub(/%%PREF%%/, pref)
  buttons = buttons + button
  end
}

tail_str = []
readHtml("daily-tail.html", tail_str)
puts buttons
tail2_str = []
readHtml("daily-tail2.html", tail2_str)
