#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0]
division = ARGV[1]
split = ARGV[2]

ncaa_asf = CSV.read("csv/ncaa_asf_#{year}_#{division}.csv",
                    "r",
                    {:col_sep => "\t", :headers => TRUE})

option_id = nil
year_stat_category_id = nil

ncaa_asf.each do |asf|
  split_name = asf["option_name"].downcase.gsub(" ","_")
  stat_category = asf["stat_category"]
  if (stat_category=="pitching" and (split_name==split))
    option_id = asf["option_id"].to_i
    year_stat_category_id = asf["year_stat_category_id"].to_i
    break
  else
    next
  end
end

ncaa_teams = CSV.read("csv/ncaa_teams_#{year}_#{division}.csv",
                      "r",
                      {:col_sep => "\t", :headers => TRUE})

ncaa_player_summaries = CSV.open("csv/ncaa_player_summaries_pitching_#{year}_#{division}_#{split}.csv",
                                 "w",
                                 {:col_sep => "\t"})

=begin
Jersey
Player
Yr
Pos
GP
GS
App
GS
ERA
IP
H
R
ER
BB
SO
SHO
BF
P-OAB
2B-A
3B-A
HR-A
WP
Bk
HB
IBB
Inh Run
Inh Run Score
SHA
SFA
Pitches
GO
FO
W
L
SV
KL
=end

ncaa_player_summaries << ["year", "year_id", "division_id",
                          "split_name", "split_id",
                          "team_id", "team_name",
                          "jersey_number",
                          "player_id", "player_name", "player_url",
                          "class_year", "position",
                          "gp", "gs", "g", "app", "gs",
                          "era", "ip", "h", "r", "er", "bb", "so", "sho",
                          "bf", "p-oab", "d-a", "t-a", "hr-a",
                          "wp", "bk", "hb", "ibb",
                          "inh_run", "inh_run_score",
                          "sha", "sfa",
                          "pitches", "go", "fo", "w", "l", "sv", "kl"]

#http://stats.ncaa.org/team/stats?id=12080&org_id=26172&year_stat_category_id=10780&available_stat_id=10288&stats_player_seq=&submit=Submit

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ncaa_teams.each do |team|

  year = team["year"]
  year_id = team["year_id"]
  team_id = team["team_id"]
  team_name = team["team_name"]

  players_xpath = '//*[@id="stat_grid"]/tbody/tr'

    stat_url = "http://stats.ncaa.org/team/#{team_id}/stats/#{year_id}?year_stat_category_id=#{year_stat_category_id}&available_stat_id=#{option_id}"

  #print "Sleep #{sleep_time} ... "
  #sleep sleep_time

  found_players = 0
  missing_id = 0

  tries = 0
  begin
    doc = agent.get(stat_url)
  rescue
    sleep_time += sleep_increment
    print "sleep #{sleep_time} ... "
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

  sleep_time = base_sleep

  print "#{year} #{team_name} ..."

  doc.search(players_xpath).each do |player|

    row = [year, year_id, division, split, option_id, team_id, team_name]
    player.xpath("td").each_with_index do |element,i|
      case i
      when 1
        player_name = element.text.strip

        link = element.search("a").first
        if (link==nil)
          missing_id += 1
          link_url = nil
          player_id = nil
          player_url = nil
        else
          link_url = link.attributes["href"].text
          parameters = link_url.split("/")[-1]

          # player_id

          player_id = parameters.split("=")[2]

          # opponent URL

          player_url = base_url+link_url
        end

        found_players += 1
        row += [player_id, player_name, player_url]
      else
        field_string = element.text.strip

        if (field_string.length==0)
          field_string=nil
        end

        row += [field_string]
      end
    end

    ncaa_player_summaries << row
    
  end

  print " #{found_players} players, #{missing_id} missing ID\n"

end
