#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

base_sleep = 0
sleep_increment = 3
retries = 4

ncaa_teams = CSV.open("csv/ncaa_teams.csv","r",{:col_sep => "\t", :headers => TRUE})
ncaa_team_schedules = CSV.open("csv/ncaa_team_schedules.csv","w",{:col_sep => "\t"})

# Header for team file

ncaa_team_schedules << ["year", "year_id", "team_id", "team_name", "game_date", "game_string", "opponent_id", "opponent_name", "opponent_url", "neutral_site", "neutral_location", "home_game", "score_string", "team_won", "score", "team_score", "opponent_score", "overtime", "overtime_periods", "game_id", "game_url"]

# Base URL for relative team links

base_url = 'http://stats.ncaa.org'

sleep_time = base_sleep

ncaa_teams.each do |team|

  year = team[0]
  year_id = team[1]
  team_id = team[2]
  team_name = team[3]

  game_xpath = '//*[@id="contentArea"]/table/tr[2]/td[1]/table/tr[position()>2]'

  team_schedule_url = "http://stats.ncaa.org/team/index/#{year_id}?org_id=#{team_id}"

  print "Sleep #{sleep_time} ... "
  sleep sleep_time

  found_games = 0
  finished_games = 0
  won = 0
  lost = 0

  tries = 0
  begin
    doc = Nokogiri::HTML(open(team_schedule_url))
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

  doc.xpath(game_xpath).each do |game|

    row = [year, year_id, team_id, team_name]
    game.xpath("td").each_with_index do |element,i|
      case i
      when 0
        game_date = element.text.strip
        row += [game_date]
      when 1
        game_string = element.text.strip
        opponent_string = game_string.split(" @ ")[0]
        neutral = game_string.split(" @ ")[1]

        if (neutral==nil)
          neutral_site = FALSE
          neutral_location = nil
        else
          neutral_site = TRUE
          neutral_location = neutral.strip
        end
        if (opponent_string.include?("@"))
          home_game = FALSE
        else
          home_game = TRUE
        end

        opponent_name = opponent_string.gsub("@","").strip

        link = element.search("a").first
        if (link==nil)
          link_url = nil
          opponent_id = nil
          opponent_url = nil
        else
          link_url = link.attributes["href"].text
          parameters = link_url.split("/")[-1]

          # opponent_id

          opponent_id = parameters.split("=")[1]

          # opponent URL

          opponent_url = base_url+link_url
        end

        row += [game_string, opponent_id, opponent_name, opponent_url, neutral_site, neutral_location, home_game]
      when 2
        score_string = element.text.strip
        score_parameters = score_string.split(" ",2)
        if (score_parameters.size>1)
          if (score_parameters[0]=="W")
            team_won = TRUE
          else
            team_won = FALSE
          end

          scores = score_parameters[1].split("(")
          score = scores[0].strip

          team_score = score.split("-")[0].strip
          opponent_score = score.split("-")[1].strip

          if (scores[1]==nil)
            overtime = FALSE
            overtime_periods = nil
          else
            overtime = TRUE
            overtime_periods = scores[1].gsub(")","").strip
          end

        else
          team_won = nil
          score = nil
          team_score = nil
          opponent_score = nil
          overtime = nil
          overtime_periods = nil
        end

        link = element.search("a").first
        if (link==nil)
          link_url = nil
          game_id = nil
          game_url = nil
        else
          link_url = link.attributes["href"].text
          parameters = link_url.split("/")[-1]

          # NCAA game_id
          game_id = parameters.split("?")[0]

          # NCAA team_id
          #opponent_id = parameters.split("=")[1]

          # opponent URL

          game_url = base_url+link_url
        end

        found_games += 1
        if not(score==nil)
          finished_games += 1
          if (team_won)
            won += 1
          else
            lost += 1
          end
        end

        row += [score_string, team_won, score, team_score, opponent_score, overtime, overtime_periods, game_id, game_url]
      end
    end

    ncaa_team_schedules << row
    
  end

  print " #{found_games} scheduled, #{finished_games} completed, record #{won}-#{lost}\n"

end
