#!/usr/bin/ruby1.9.1

require "csv"
require "mechanize"

#game_date,conference_id,conference_name,home_team,home_team_site,away_team,away_team_site,time/score,boxscore_link,webcast_text,webcast_javascript

agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0'

base="http://www.dakstats.com/WebSync/Pages/Team/TeamSchedule.aspx"
#?association=10

header = ["comp_id","conference_id","conference_name","game_date","home_name","home_href","home_id","away_name","away_href","away_id","score","time","conf_game","status","box_score_href"]

association="10"
sg="MBA"

#&sea=NAIMBA_2011&conference=NAIMBA1_AMEC"

teams = CSV.read("teams.csv")

first_year = 2012
last_year = 2012

(first_year..last_year).each do |year|

  games = CSV.open("naia_team_games_#{year}.csv","w")

  games << header

  sea = "NAIMBA_#{year}"

  teams.each do |team|
    team_id = team[5]
    team_name = team[0]
    print "Pulling #{year} - #{team_name}\n"
    url = "#{base}?association=#{association}&sg=#{sg}&sea=#{sea}&team=#{team_id}"

    begin
      page = agent.get(url) #   page = agent.get(url)
    rescue
      print "Error: Retrying\n"
      retry
      #print "missing\n"
    end

    path = "//table[(@id='ctl00_websyncContentPlaceHolder_quickScheduleDataList')]"
#    path = "//table[(@id='contentTable')]"
#    path = "/html/body/form/table[2]/tr/td/table/tr[3]/td/div/div/div[2]/table/tr/td/table"

    page.parser.xpath(path).each do |t|
      t.css("tr").each do |tr|
        row = []
        tr.css("td").each do |td|
          row << td.text.strip
        end
        if (row.size>1) then
          p row
        end
      end
    end

    exit

=begin
    rows = []
    row = []
    game_date = nil
#"/html/body/form/table[2]/tbody/tr/td/table/tbody/tr[3]/td/div/div/div[2]/table/tbody/tr/td/table").each do |t|
    path = "table[(@id='contentTable')]"
    #p page.parser.xpath(path)
    page.parser.xpath(path).each do |t|
      p t.children
      p t.path
      p t.children.size
      t.children.each do |c|
        p c.path
      end
    end
    exit

=end

#/html/body/form/table[2]/tbody/tr/td/table/tbody/tr[3]/td/div/div/div[2]/table/tbody/tr/td/table/tbody/tr[22]/td

  end



#  games.close

end
