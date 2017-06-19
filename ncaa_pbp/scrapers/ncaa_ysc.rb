#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = 1 #ARGV[1]

ncaa_teams = CSV.read("csv/ncaa_teams_#{year}_#{division}.csv","r",{:col_sep => "\t", :headers => TRUE})
ncaa_ysc = CSV.open("csv/ncaa_ysc_#{year}.csv","w",{:col_sep => "\t"})

ncaa_ysc << ["year", "year_id", "stat_category", "year_stat_category_id"]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ysc_xpath = '//*[@id="stats_div"]/table[1]/tr/td/a[1]'

team = ncaa_teams.first

year_id = team["year_id"].to_i
team_id = team["team_id"].to_i

#stat_url = "http://stats.ncaa.org/team/stats?org_id=#{team_id}&sport_year_ctl_id=#{year_id}"

stat_url = "http://stats.ncaa.org/team/#{team_id}/stats/#{year_id}"

tries = 0
begin
  doc = agent.get(stat_url)
rescue
  sleep_time += sleep_increment
  print "sleep #{sleep_time} ... "
  sleep sleep_time
  tries += 1
  if (tries > retries)
    exit
  else
    retry
  end
end

# Pitching

a = doc.search(ysc_xpath).first
href = a.attribute("href").text

year_stat_category_id = href.split("=")[2].to_i

# Hitting = Pitching-1
# Fielding = Pitching+1

ncaa_ysc << [year, year_id, "hitting", year_stat_category_id-1]
ncaa_ysc << [year, year_id, "pitching", year_stat_category_id]
ncaa_ysc << [year, year_id, "fielding", year_stat_category_id+1]

ncaa_ysc.close
