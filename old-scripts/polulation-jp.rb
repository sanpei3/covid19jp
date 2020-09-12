require "./util"
require "csv"
CSV.foreach("Polulation.csv", "r:UTF-8") do |row|
  pref = $pref_en[:"#{row[0]}"]
  puts "#{pref},#{row[1]}"
end
