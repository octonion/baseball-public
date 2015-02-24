#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"

nbsp = Nokogiri::HTML("&nbsp;").text

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.njcaa.org/sports_schedules.cfm"

category="Schedules%2FScores"

divid=1
sid=divid+6
gender="m"
slid=3
month=2
day=17
year=2008

found = 0

header = ["division_id","sent_date","pulled_date",
          "visitor_name","visitor_id","visitor_college_id",
          "vistor_href","visitor_record","visitor_score",
          "park_name",
          "home_name","home_id","home_college_id",
          "home_href","home_record","home_score",
          "status"]

#header = ["division_id","sent_date","pulled_date",
#          "visitor_name","visitor_id","visitor_college_id",
#          "vistor_href","visitor_record","visitor_record_href",
#          "visitor_score","visitor_score_href",
#          "park_name",
#          "home_name","home_id","home_college_id",
#          "home_href","home_record","home_record_href",
#          "home_score","home_score_href",
#          "status"]

today = Date.today

first_year = 2012
last_year = 2012
#last_year = today.year

(first_year..last_year).each do |year|

#  records = CSV.open("njcaa_records_#{year}.csv","w")
  games = CSV.open("csv/njcaa_games_#{year}.csv","w")
  games << header

  start = Date.new(year, 1, 1)
  finish = Date.new(year, 12, 31)

  (1..3).each do |divid|

    game_count = 0

    sid = divid+6

    (start..finish).each do |date|
      
      if (date > Date.today)
        break
      end

      pulled_date = nil

      year = date.year
      month = date.month
      day = date.day

      sent_date = "#{month}/#{day}/#{year}"

      print "NJCAA D#{divid} (#{sent_date}) (#{game_count})\n"

      url = "#{base}?menu=4&sid=#{sid}&divid=#{divid}&slid=#{slid}&month=#{month}&day=#{day}&year=#{year}"

      begin
        page = agent.get(url)
      rescue
        print "missing\n"
        next
      end

      row = []
      page.parser.xpath("/html/body/center/table[2]/tr[2]/td[1]/div/div/table").children.each do |c|
        if (c.path =~ /\/tr\[(\d+)\]\z/)
          c.xpath("td").each do |d|
            if (d.path =~ /td\z/) or (d.path =~ /tr\[2\]\/td\[3\]\z/) # end game
              if (pulled_date==nil)
                pulled_date = d.text.gsub("\r","").gsub("\n","").gsub("\t","").strip
                row += [sent_date,pulled_date]
              else
                status = d.text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(nbsp," ").strip            
                row += [status]
                #p row.size
                if (row.size >= 10)
                  game_count += 1
                  #games << [divid]+row

                  visitor_name = row[2].strip

                  visitor_id = row[3][/teamid=(\d+)/]
                  if not(visitor_id==nil)
                    visitor_id = visitor_id[/(\d+)/]
                  end
                  visitor_college_id = row[3][/collegeId=(\d+)/]
                  if not(visitor_college_id==nil)
                    visitor_college_id = visitor_college_id[/(\d+)/]
                  end

                  home_id = row[9][/teamid=(\d+)/]
                  if not(home_id==nil)
                    home_id = home_id[/(\d+)/]
                  end
                  home_college_id = row[9][/collegeId=(\d+)/]
                  if not(home_college_id==nil)
                    home_college_id = home_college_id[/(\d+)/]
                  end

                  if (row[8].include?("@"))
                    home_name = row[8].gsub("@","").strip
                    park_name = home_name
                  else
                    home_name = row[8].strip
                    park_name = "neutral"
                  end

                  if (row[9].include?("@"))
                    home_href = row[9].gsub("@","").strip
                  else
                    home_href = row[9].strip
                  end

                  games << [divid,row[0],row[1],
                            visitor_name,visitor_id,visitor_college_id,
                            row[3],row[4],row[6],
                            park_name,
                            home_name,home_id,home_college_id,
                            home_href,row[10],row[12],row[14]]
                end
                row = [sent_date,pulled_date]
              end
            else
              if not(d.path =~ /text()/)
                text = d.text.gsub("\r","").gsub("\n","").gsub("\t","").strip
                html = d.inner_html.gsub("\r","").gsub("\n","").gsub("\t","").strip
                row += [text,html]
              end
            end
          end
        else
          if not(c.path =~ /text()/)
            text = c.text.gsub("\r","").gsub("\n","").gsub("\t","").strip
            html = c.inner_html.gsub("\r","").gsub("\n","").gsub("\t","").strip
            row += [text,html]
          end
        end
      end

#header = ["division_id","sent_date","pulled_date",
#          "visitor","vistor_href","visitor_record","visitor_record_href",
#          "visitor_score","visitor_score_href",
#          "home","home_href","home_record","home_record_href",
#          "home_score","home_score_href",
#          "status"]

      if (row.size>=14)
        visitor_name = row[2].strip

        visitor_id = row[3][/teamid=(\d+)/]
        if not(visitor_id==nil)
          visitor_id = visitor_id[/(\d+)/]
        end
        visitor_college_id = row[3][/collegeId=(\d+)/]
        if not(visitor_college_id==nil)
          visitor_college_id = visitor_college_id[/(\d+)/]
        end

        home_id = row[9][/teamid=(\d+)/]
        if not(home_id==nil)
          home_id = home_id[/(\d+)/]
        end
        home_college_id = row[9][/collegeId=(\d+)/]
        if not(home_college_id==nil)
          home_college_id = home_college_id[/(\d+)/]
        end

        if (row[8].include?("@"))
          home_name = row[8].gsub("@","").strip
          park_name = home_name
        else
          home_name = row[8].strip
          park_name = "neutral"
        end

        if (row[9].include?("@"))
          home_href = row[9].gsub("@","").strip
        else
          home_href = row[9].strip
        end

        if (row.size == 14) # No status
          game_count += 1
          games << [divid,row[0],row[1],
                    visitor_name,visitor_id,visitor_college_id,
                    row[3],row[4],row[6],
                    park_name,
                    home_name,home_id,home_college_id,
                    home_href,row[10],row[12],""]
        elsif (row.size == 15)
          game_count += 1
          games << [divid,row[0],row[1],
                    visitor_name,visitor_id,visitor_college_id,
                    row[3],row[4],row[6],
                    park_name,
                    home_name,home_id,home_college_id,
                    home_href,row[10],row[12],row[14]]
        end
      end

      games.flush
    end
  end
  games.close

end
