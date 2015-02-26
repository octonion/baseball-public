#!/usr/bin/ruby

require "hpricot"
require "rest-open-uri"
require "csv"

user_agent = "Mozilla/5.0"

teams = CSV.open("teams.csv","r",
                 {:headers => true, :return_headers => false,
                  :header_converters => :symbol, :converters => :all})

base = "http://www.pointstreak.com/baseball/api/index.php"

print "\n"
teams.each do |team|

  league_id = team[:league_id]
  season_id = team[:season_id]
  team_id = team[:team_id]

  print "Pulling statistics for league_id=#{league_id}, season_id=#{season_id}, team_id=#{team_id}\n"

  action = "team_battingleaders"
  body = "action=#{action}&teamid=#{team_id}&seasonid=#{season_id}"
  url = "#{base}?#{body}"

  begin
    @response = open(url, "User-Agent" => user_agent,
                     :method => :get).read
  rescue
    print "Error: Retrying\n"
    retry
  end

  html = @response

  file = File.open("XML/#{team_id}_batting.xml","w")
  file << html
  file.close

  action = "team_pitchingleaders"
  body = "action=#{action}&teamid=#{team_id}&seasonid=#{season_id}"
  url = "#{base}?#{body}"

  begin
    @response = open(url, "User-Agent" => user_agent,
                     :method => :get).read
  rescue
    print "Error: Retrying\n"
    retry
  end

  html = @response

  file = File.open("XML/#{team_id}_pitching.xml","w")
  file << html
  file.close

end
