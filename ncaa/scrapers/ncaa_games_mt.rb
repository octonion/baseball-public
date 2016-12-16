#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

bad = '%'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

search_url = "http://web1.ncaa.org/stats/exec/records"

games_header = ["year","team_name","team_id","opponent_name","opponent_id",
                "game_date","team_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","team_id","team_name","wins","losses","ties",
                  "total_games"]

game_xpath = "//table/tr[3]/td/form/table[2]/tr"
record_xpath = "//table/tr[3]/td/form/table[1]/tr[2]"

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

first_year = 2016
last_year = 2016

(first_year..last_year).each do |year|

  games = CSV.open("csv/ncaa_games_mt_#{year}.csv",
                        "w", {:col_sep => ","})
  records = CSV.open("csv/ncaa_records_mt_#{year}.csv",
                          "w", {:col_sep => ","})

  games << games_header
  records << records_header

  threads = []

  schools.each_slice(gpt).with_index do |schools_slice,i|

    threads << Thread.new(schools_slice) do |t_schools|

      agent = Mechanize.new{ |agent| agent.history.max_size=0 }

      agent.user_agent = 'Mozilla/5.0'

      agent.get(search_url)

      #found = 0
      n_t = t_schools.size

      t_schools.each_with_index do |school,j|

        school_id = school[0]
        school_name = school[1]

        team_count = 0
        game_count = 0

        print "#{i}:#{j}/#{n_t} - #{year}/#{school_name}\n"

        begin
          page = agent.post(search_url, {"academicYear" => "#{year}",
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
          page.parser.xpath(record_xpath).each do |tr|
            row = [year,school_id]
            tr.xpath("td").each do |td|
              row += [td.text.strip]
            end
            team_count += 1
            records << row
          end
          #records.flush
        end

        page.parser.xpath(game_xpath).each do |tr|

          row = []
          tr.xpath("td").each do |td|

            a = td.xpath("a").first
            if not(a==nil)
              text = a.inner_text
              text = text.gsub(bad,"").strip
              url = a.attributes["href"].value.strip
            else
              text = td.inner_text
              text = text.gsub(bad,"").strip
              url = nil
            end
            row += [text, url]

          end
          if (row[0]=="Opponent")
            next
          end
          if not(row[1]==nil)
            opponent_id = row[1][/(\d+)/]
          else
            opponent_id=nil
          end

          game_count += 1

          rr = [year, school_name, school_id,row[0], opponent_id,
                row[2],row[4],row[6],row[8],row[10],row[12],row[14]]

          rr.map!{ |e| e=='' ? nil : e }

          games << rr

        end

      end
    end
  end

  threads.each(&:join)
  games.close
  records.close
end

