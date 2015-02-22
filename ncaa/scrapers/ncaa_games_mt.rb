#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

games_url = "http://web1.ncaa.org/stats/exec/records"

games_header = ["year","team_name","team_id","opponent_name","opponent_id",
                "game_date","team_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","team_id","team_name","wins","losses","ties",
                  "total_games"]

game_xpath = "//table/tr[3]/td/form/table[2]/tr"
record_xpath = "//table/tr[3]/td/form/table[1]/tr[2]"

nthreads = 6

base_sleep = 0
sleep_increment = 3
retries = 4

schools = []
CSV.open("csv/ncaa_schools.csv").each do |school|
    schools << school
end

n = schools.size
gpt = (n.to_f/nthreads.to_f).ceil

first_year = 1997
last_year = 2013

(first_year..last_year).each do |year|

  ncaa_games = CSV.open("csv/ncaa_games_mt_#{year}.csv",
                        "w", {:col_sep => ","})
  ncaa_records = CSV.open("csv/ncaa_records_mt_#{year}.csv",
                          "w", {:col_sep => ","})

  ncaa_games << games_header
  ncaa_records << records_header

  threads = []

  schools.each_slice(gpt).with_index do |schools_slice,i|

    threads << Thread.new(schools_slice) do |t_schools|

      agent = Mechanize.new{ |agent| agent.history.max_size=0 }

      agent.user_agent = 'Mozilla/5.0'

      agent.get(games_url)

      #found = 0
      n_t = t_schools.size

      t_schools.each_with_index do |school,j|

        school_id = school[0]
        school_name = school[1]

        team_count = 0
        game_count = 0

        print "#{i}:#{j}/#{n_t} - #{year}/#{school_name}\n"

        begin
          page = agent.post(games_url, {"academicYear" => "#{year}",
                              "orgId" => school_id,
                              "sportCode" => "MBA"})
        rescue
          print "  -> error, retrying\n"
          retry
        end

        if !(page.class==Mechanize::Page)
          next
        end

        begin
          page.parser.xpath(record_xpath).each do |row|
            r = []
            row.xpath("td").each do |d|
              r += [d.text.strip]
            end
            team_count += 1
            ncaa_records << [year,school_id]+r
          end
        end

        page.parser.xpath(game_xpath).each do |row|
          r = []
          row.xpath("td").each do |d|
            r += [d.text.strip,d.inner_html.strip]
          end
          if (r[0]=="Opponent")
            next
          end
          opponent_id = r[1][/(\d+)/]
          game_count += 1

          rr = [year,school_name,school_id,r[0],opponent_id,
                r[2],r[4],r[6],r[8],r[10],r[12],r[14]]

          rr.map!{ |e| e=='' ? nil : e }

          ncaa_games << rr

        end

      end
    end
  end

  threads.each(&:join)
  ncaa_games.close
  ncaa_records.close
end

