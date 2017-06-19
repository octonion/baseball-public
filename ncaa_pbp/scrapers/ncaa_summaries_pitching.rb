#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_sleep = 0
sleep_increment = 3
retries = 4

year = ARGV[0].to_i
division = ARGV[1]

ncaa_teams = CSV.read("csv/ncaa_teams_#{year}_#{division}.csv","r",{:col_sep => "\t", :headers => TRUE})
ncaa_player_summaries = CSV.open("csv/ncaa_player_summaries_pitching_#{year}_#{division}.csv","w",{:col_sep => "\t"})
ncaa_team_summaries = CSV.open("csv/ncaa_team_summaries_pitching_#{year}_#{division}.csv","w",{:col_sep => "\t"})

ncaa_ysc = CSV.read("csv/ncaa_ysc_#{year}.csv",
                    "r",
                    {:col_sep => "\t", :headers => TRUE})

year_id = nil
year_stat_category_id = nil

ncaa_ysc.each do |ysc|
  stat_category = ysc["stat_category"]
  if (stat_category=="pitching")
    year_id = ysc["year_id"].to_i
    year_stat_category_id = ysc["year_stat_category_id"].to_i
    break
  else
    next
  end
end

# Headers for files

#Jersey	Player	Yr	Pos	GP	GS	G	App	GS	ERA	IP	H	R	ER	BB	SO	SHO	BF	P-OAB	2B-A	3B-A	HR-A	WP	Bk	HB	IBB	Inh Run	Inh Run Score	SHA	SFA	Pitches	GO	FO	W	L	SV	KL

ncaa_player_summaries << [
"year", "year_id", "division_id",
"team_id", "team_name",
"jersey_number", "player_id", "player_name", "player_url",
"class_year", "position",
"gp", "gs", "g", "app", "gs2",
"era", "ip",
"h", "r", "er", "bb", "so", "sho", "bf", 
"p_oab", "d_allowed", "t_allowed", "hr_allowed",
"wp", "bk", "hb", "ibb",
"inh_run", "inh_run_score",
"sha", "sfa", "pitches", "go", "fo",
"w", "l", "sv", "kl"]

ncaa_team_summaries << [
"year", "year_id", "division_id",
"team_id", "team_name",
"jersey_number", "player_name",
"class_year", "position",
"gp", "gs", "g", "app", "gs2",
"era", "ip",
"h", "r", "er", "bb", "so", "sho", "bf", 
"p_oab", "d_allowed", "t_allowed", "hr_allowed",
"wp", "bk", "hb", "ibb",
"inh_run", "inh_run_score",
"sha", "sfa", "pitches", "go", "fo",
"w", "l", "sv", "kl"]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ncaa_teams.each do |team|

  year = team["year"]
  year_id = team["year_id"]
  team_id = team["team_id"]
  team_name = team["team_name"]

  players_xpath = '//*[@id="stat_grid"]/tbody/tr'

  teams_xpath = '//*[@id="stat_grid"]/tfoot/tr' #[position()>1]'

    stat_url = "http://stats.ncaa.org/team/#{team_id}/stats?id=#{year_id}&year_stat_category_id=#{year_stat_category_id}"

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

    row = [year, year_id, division, team_id, team_name]
    player.search("td").each_with_index do |element,i|
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
        field_string = element.text.strip rescue nil
        field_string.gsub!(",","") rescue nil
        row += [field_string]
      end
    end

    ncaa_player_summaries << row
    
  end

  print " #{found_players} players, #{missing_id} missing ID"

  found_summaries = 0
  doc.search(teams_xpath).each do |team|

    row = [year, year_id, team_id, team_name]
    team.search("td").each_with_index do |element,i|
      field_string = element.text.strip rescue nil
      field_string.gsub!(",","") rescue nil
      row += [field_string]
    end

    found_summaries += 1
    ncaa_team_summaries << row
    
  end

  print ", #{found_summaries} team summaries\n"

end
