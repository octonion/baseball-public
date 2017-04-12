#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

base_url = 'http://stats.ncaa.org'

box_scores_xpath = '//*[@id="contentArea"]/table[position()>4]/tr[position()>2]'

nthreads = 1

base_sleep = 0
sleep_increment = 3
retries = 4

schools = []
CSV.open("csv/ncaa_schools.csv").each do |school|
    schools << school
end

n = schools.size
gpt = (n.to_f/nthreads.to_f).ceil

first_year = 2017
last_year = 2017

(first_year..last_year).each do |year|

  ncaa_player_statistics = CSV.open("csv/ncaa_player_statistics_mt_#{year}.csv","w", {:col_sep => "\t"})

  header = ["team_name", "team_id", "year", "player_name", "player_id",
            "class_year", "season_year", "position",
            "games", "ab", "runs", "hits", "avg",
            "doubles", "triples", "hr", "total_bases", "slg",
            "rbi", "sb", "sba", "bb", "so", "hbp", "sac_hits", "sac_flies",
            "appearances", "games_started", "complete_games",
            "wins", "losses", "saves", "shutouts",
            "ip", "hits", "runs", "earned_runs", "bb", "so", "era"]

  ncaa_player_statistics << header

  threads = []

  schools.each_slice(gpt).with_index do |schools_slice,i|

    threads << Thread.new(schools_slice) do |t_schools|

      agent = Mechanize.new{ |agent| agent.history.max_size=0 }

      agent.user_agent = 'Mozilla/5.0'

      # Needed for referer

      url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
      agent.get(url)

      found = 0
      n_t = t_schools.size

      t_schools.each_with_index do |school,j|

        school_id = school[0]
        school_name = school[1]
        print "#{i}:#{j}/#{n_t} - #{year}/#{school_name}\n"

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

        page.parser.xpath("//table[5]/tr").each do |row|
          if (row.path =~ /\/tr\[[123]\]\z/)
            next
          end
          r = [school_name,school_id,year]
          row.xpath("td").each_with_index do |d,i|

            text = d.text.strip rescue nil
            if (text=="-")
              text = ""
            end

            text = text.to_nil rescue nil
            
            if (i==0) then
              id = d.inner_html.strip[/(\d+)/].to_i
              r += [text,id]
            else
              r += [text]
            end
          end
          if not(r[3]==nil)
            ncaa_player_statistics << r
          end
          #ncaa_player_statistics.flush
        end
      end

    end

  end

  threads.each(&:join)
  ncaa_player_statistics.close
end
