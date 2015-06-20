#!/usr/bin/env ruby

require "hpricot"
#require "rest-open-uri"
require "csv"

user_agent = "Mozilla/5.0"

leagues = CSV.open("leagues.csv","w")

leagues << ["league_id"]

url = "http://www.pointstreak.com/baseball/index.html"

begin
  @response = open(url, "User-Agent" => user_agent,
                   :method => :get).read
rescue
  print "Error: Retrying\n"
  retry
end

html = @response

html.scan(/leagueid=(\d*)/).sort.uniq.each do |league_id|
  leagues << [league_id[0].to_i]
end

leagues.close
