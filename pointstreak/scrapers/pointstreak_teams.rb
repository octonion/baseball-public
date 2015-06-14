#!/usr/bin/ruby

require "hpricot"
#require "rest-open-uri"
require "csv"

user_agent = "Mozilla/5.0"

leagues = CSV.open("leagues.csv","r",
                   {:headers => true, :return_headers => false,
                    :header_converters => :symbol, :converters => :all})

teams = CSV.open("teams.csv","w")

teams << ["league_id","season_id","team_id"]

base = "http://www.pointstreak.com/baseball/standings.html"

leagues.each do |league|

  league_id = league[:league_id]

  url = "#{base}?leagueid=#{league_id}"

  begin
    @response = open(url, "User-Agent" => user_agent,
                     :method => :get).read
  rescue
    print "Error: Retrying\n"
    retry
  end

  html = @response

  season_id = html.scan(/leagueid=#{league_id}&seasonid=(\d*)/)[0][0].to_i

  team_array = html.scan(/teamid=(\d*)/).sort.uniq

  team_array.each do |team_id|
    teams << [league_id,season_id,team_id[0].to_i]
  end

  n = team_array.size

  print "league_id = #{league_id}, season_id = #{season_id}, found #{n} teams\n"

end

teams.close
leagues.close
