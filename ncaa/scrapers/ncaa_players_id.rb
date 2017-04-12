#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

# Needed for referer

url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
agent.get(url)

schools = CSV.read("csv/ncaa_schools.csv")

first_year = 2017
last_year = 2017

(first_year..last_year).each do |year|
  stats = CSV.open("csv/ncaa_players_#{year}.csv","w")

  header = ["team_name", "team_id", "year", "player_name", "player_id",
            "class_year", "season_year", "position",
            "games", "ab", "runs", "hits", "avg",
            "doubles", "triples", "hr", "total_bases", "slg",
            "rbi", "sb", "sba", "bb", "so", "hbp", "sac_hits", "sac_flies",
            "appearances", "games_started", "complete_games",
            "wins", "losses", "saves", "shutouts",
            "ip", "hits", "runs", "earned_runs", "bb", "so", "era"]

  stats << header

  schools.each do |school|

    school_id = school[0]
    school_name = school[1]
    print "#{year}/#{school_name}\n"

    begin
      page = agent.post(url, {
                          "academicYear" => "#{year}",
                          "orgId" => school_id,
                          "sportCode" => "MBA",
                          "sortOn" => "0",
                          "doWhat" => "display",
                          "playerId" => "-100",
                          "coachId" => "-100",
                          "division" => "1",
                          "idx" => ""
                        })
    rescue
      print "  -> error, retrying\n"
      retry
    end

    #/html/body/form/table[5]/tr[3],N
    page.parser.xpath("//table[5]/tr").each do |row|
      if (row.path =~ /\/tr\[[123]\]\z/)
        next
      end
      r = [school_name,school_id,year]
      row.xpath("td").each_with_index do |d,i|
        if (i==0) then
          id = d.inner_html.strip[/(\d+)/].to_i
          r += [d.text.strip,id]
          #d.inner_html.strip
        else
          r += [d.text.strip]
        end
      end
      #    if (r[0]=="Opponent")
      #      next
      #    end
      #    opponent_id = r[1][/(\d+)/]
      #    p row.path
      stats << r
      stats.flush
    end
  end

  stats.close
end
