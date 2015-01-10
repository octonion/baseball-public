#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

base_sleep = 0
sleep_increment = 3
retries = 4

ncaa_teams = CSV.open("csv/ncaa_teams.csv","r",{:col_sep => "\t", :headers => TRUE})
ncaa_player_summaries = CSV.open("csv/ncaa_player_hitting_summaries.csv","w",{:col_sep => "\t"})
ncaa_team_summaries = CSV.open("csv/ncaa_team_hitting_summaries.csv","w",{:col_sep => "\t"})

#http://stats.ncaa.org/team/roster/11540?org_id=2

# Headers for files

#Jersey	Player	Yr	Pos
#GP	GS	G	BA	OBPct	SlgPct
#AB	R	H	2B	3B	TB	HR	RBI	BB	HBP
#SF	SH	K	DP	SB	CS	Picked

ncaa_player_summaries << [
"year", "year_id", "team_id", "team_name",
"jersey_number", "player_id", "player_name", "player_url", "class_year",
"position",
"gp", "gs", "g", "ba", "obp", "slg",
"ab", "r", "h", "d", "t", "tb", "hr", "rbi", "bb", "hbp",
"sf", "sh", "k", "dp", "sb", "cs", "picked"]

ncaa_team_summaries << ["year","year_id","team_id","team_name",
"jersey_number", "player_name", "class_year", "position",
"gp", "gs", "g", "ba", "obp", "slg",
"ab", "r", "h", "d", "t", "tb", "hr", "rbi", "bb", "hbp",
"sf", "sh", "k", "dp", "sb", "cs", "picked"]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ncaa_teams.each do |team|

  year = team[0]
  year_id = team[1]
  team_id = team[2]
  team_name = team[3]

  players_xpath = '//*[@id="stat_grid"]/tbody/tr'

  teams_xpath = '//*[@id="stat_grid"]/tfoot/tr' #[position()>1]'

  stat_url = "http://stats.ncaa.org/team/stats?org_id=#{team_id}&sport_year_ctl_id=#{year_id}"

  #print "Sleep #{sleep_time} ... "
  #sleep sleep_time

  found_players = 0
  missing_id = 0

  tries = 0
  begin
    doc = Nokogiri::HTML(open(stat_url))
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

  doc.xpath(players_xpath).each do |player|

    row = [year, year_id, team_id, team_name]
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

        row += [field_string]
      end
    end

    ncaa_player_summaries << row
    
  end

  print " #{found_players} players, #{missing_id} missing ID"

  found_summaries = 0
  doc.xpath(teams_xpath).each do |team|

    row = [year, year_id, team_id, team_name]
    team.xpath("td").each_with_index do |element,i|
        field_string = element.text.strip
        row += [field_string]
    end

    found_summaries += 1
    ncaa_team_summaries << row
    
  end

  print ", #{found_summaries} team summaries\n"

end
