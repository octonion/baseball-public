#!/usr/bin/env ruby

require "csv"
require "mechanize"
require "nokogiri"
require "open-uri"

#game_date,conference_id,conference_name,home_team,home_team_site,away_team,away_team_site,time/score,boxscore_link,webcast_text,webcast_javascript

agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0'

base="http://www.dakstats.com/WebSync/Pages/Team/TeamSchedule.aspx"
#?association=10

#header = ["comp_id","conference_id","conference_name","game_date","home_name","home_href","home_id","away_name","away_href","away_id","score","time","conf_game","status","box_score_href"]

header = ["team_name","team_id","parsed_team_id","opponent_id","comp_id","conf_game","year","game_date","opponent_name","location","score","outcome","webcast_url"]

association="10"
sg="MBA"

#&sea=NAIMBA_2011&conference=NAIMBA1_AMEC"

teams = CSV.read("csv/teams.csv")

first_year = 2015
last_year = 2015

(first_year..last_year).each do |year|

  games = CSV.open("csv/naia_team_games_#{year}.csv","w")

  games << header

  sea = "NAIMBA_#{year}"

  teams.each do |team|
    team_id=team[0]
    team_name = team[1]
    print "Pulling #{year} - #{team_name}\n"
    url = "#{base}?association=#{association}&sg=#{sg}&sea=#{sea}&team=#{team_id}"

    begin
      page = Nokogiri::HTML(open(url)) #   page = agent.get(url)
    rescue
      print "Error: Retrying\n"
      retry
      #print "missing\n"
    end

#    path = "table[(@id='ctl00_websyncContentPlaceHolder_quickScheduleDataList')]"
    path = "/html/body/form/table[2]/tr/td/table/tr[3]/td/div/div/div[2]/table/tr/td/table"

    page.xpath(path).each do |t|
      t.xpath("tr").each do |tr|

        parsed_team_id = [nil]
        opponent_id = [nil]
        comp_id = [nil]
        conf_game = [FALSE]

        row = []
        tr.xpath("td").each_with_index do |td,i|

          text = td.text.strip

          if (i==1) then

            if (text =~ /\*$/) then
              conf_game = [TRUE]
              text = text.gsub("*","").strip
            end

            html=Nokogiri::HTML(td.inner_html)
            
            a=html.css("a")[0]

            html.css("a").each do |a|
            #if not(a==nil)
              href = a["href"]
              if not(href==nil)
                string = href.split("?")[1]
                parameters = CGI::parse(string)
                opponent_id = parameters["team"]
              end
            end
          end

          if (i==3) then
            html=Nokogiri::HTML(td.inner_html)

            html.css("a").each do |a|
              if not(a==nil)
                href = a["href"]
                if not(href==nil)
                  string = href.split("?")[1]
                  parameters = CGI::parse(string)
                  parsed_team_id = parameters["team"]
                  comp_id = parameters["compID"]
                end
              end
            end

          end

          row += [text]
        end
        if (row.size>2) then
          games << [team_name,team_id]+parsed_team_id+opponent_id+comp_id+conf_game+[year]+row
        end
      end
    end
  end

  games.close

end

#          h = (team_xml/"a").first
#          if not(h==nil)
#            team_url = h.attributes["href"]
#            team_url_options = team_url.split("?")[1]
#            team_options = CGI::parse(team_url_options)
#            team_id = team_options["team"]
#          else
#            team_id = [nil]
#          end
