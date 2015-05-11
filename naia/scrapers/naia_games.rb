#!/usr/bin/env ruby

require "csv"
require "mechanize"

#game_date,conference_id,conference_name,home_team,home_team_site,away_team,away_team_site,time/score,boxscore_link,webcast_text,webcast_javascript

agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0'

#path = '//*[contains(concat( " ", @class, " " ), concat( " ", "d8", " " ))]'

path = '//*[@id="ctl00_websyncContentPlaceHolder_scheduleDataList"]//tr'

base="http://www.dakstats.com/WebSync/Pages/Conference/ConferenceSchedule.aspx"

header = ["game_date", "home_name", "home_url", "home_id",
          "away_name", "away_url", "away_id",
          "game_score", "boxscore_url",
          "association_id", "sport_id", "season_id",
          "conference_id", "game_id",
          "webcast_js", "tournament_js", "gamebook_js"]

association="10"
sg="MBA"

#&sea=NAIMBA_2011&conference=NAIMBA1_AMEC"

first_year = 2015
last_year = 2015

(first_year..last_year).each do |year|

  conferences = CSV.read("csv/naia_conferences_#{year}.csv",
                         { :headers => TRUE })

  games = CSV.open("csv/naia_games_#{year}.csv","w")
  games << header

  conferences.each do |conference|

    conference_id = conference["conference_id"]
    year = conference["year"]
    conference_name = conference["conference_name"]

    sea = "NAIMBA_#{year}"

    print "#{year} - #{conference_name}\n"
    url = "#{base}?association=#{association}&sg=#{sg}&sea=#{sea}&conference=#{conference_id}"

    begin
      page = agent.get(url)
    rescue
      print "Error: Retrying\n"
      retry
      #print "missing\n"
    end

    rows = []

    game_date = nil
    page.parser.xpath(path).each do |element|

      ec = element.parent.attr("class")

      if (ec == "subHeaderTable")
        game_date = element.text.strip
        next
      elsif (ec == nil)
        next
      end

      row = [game_date]
      element.xpath("td").each_with_index do |td,i|

        text = td.text.strip rescue nil
        a = td.xpath("a").first

        if not(a==nil)
          href = a.attr("href")
        else
          href = nil
        end

        case i
        when 0,1
          row += [text,href]
          if not(href==nil)
            p = CGI.parse(URI.parse(href).query)
            team_id = p["team"][0]
            row += [team_id]
          else
            row += [nil]
          end

        when 2
          row += [text,href]
          if not(href==nil)
            p = CGI.parse(URI.parse(href).query)
            association_id = p["association"][0]
            sport_id = p["sg"][0]
            season_id = p["sea"][0]
            conference_id = p["conference"][0]
            game_id = p["compID"][0]
            row += [association_id, sport_id, season_id, conference_id, game_id]
          else
            row += [nil, nil, nil, nil, nil]
          end

        when 3
          td.xpath("div/input").each do |input|
            onclick = input.attr("onclick")
            row += [onclick]
          end

        end

      end

      games << row

    end

  end
  games.close

end


