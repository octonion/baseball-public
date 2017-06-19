#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1].to_i

ncaa_teams = CSV.read("csv/ncaa_teams_#{year}_#{division}.csv",
                      "r",
                      {:col_sep => "\t", :headers => TRUE})

ncaa_ysc = CSV.read("csv/ncaa_ysc_#{year}.csv",
                    "r",
                    {:col_sep => "\t", :headers => TRUE})

ncaa_asf = CSV.open("csv/ncaa_asf_#{year}_#{division}.csv",
                    "w",
                    {:col_sep => "\t"})

ncaa_asf << ["year", "year_id", "stat_category", "year_stat_category_id",
            "option_name", "option_id"]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep
asf_xpath = '//*[@id="available_stat_id"]/option[position()>1]'

team = ncaa_teams.first

#year_id = team["year_id"].to_i
team_id = team["team_id"].to_i

ncaa_ysc.each do |ysc|

  year = ysc["year"].to_i
  year_id = ysc["year_id"].to_i
  stat_category = ysc["stat_category"]
  ysc_id = ysc["year_stat_category_id"].to_i

  stat_url = "http://stats.ncaa.org/team/#{team_id}/stats?id=#{year_id}&year_stat_category_id=#{ysc_id}"

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

  doc.parser.xpath(asf_xpath).each do |option|
    option_name = option.text
    #option_id = option.attributes["value"].text.to_i
    option_id = option.attribute("value").text.to_i

    row = [year, year_id, stat_category, ysc_id, option_name, option_id]

    ncaa_asf << row
    
  end

end

ncaa_asf.close
