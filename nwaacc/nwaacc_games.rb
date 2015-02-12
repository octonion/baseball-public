#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

header = ["year","game_date","result","result_url"]

first_year = 2012
last_year = 2012

(first_year..last_year).each do |year|

  games = CSV.open("nwaacc_games_#{year}.csv","w")
  games << header

  if (year==2011)
    base = "http://www.nwaacc.org/baseball/"
    url = "http://www.nwaacc.org/baseball/results.php"
  else
    base = "http://www.nwaacc.org/baseball/archive/#{year}/"
    url = "http://www.nwaacc.org/baseball/archive/#{year}/results.php"
  end

  games_xpath = "//table/tr"
  found = 0
  print "NWAACC #{year}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  game_date = nil
  game_result = nil
  page.parser.xpath("//table/tr/td/div/div").children.each do |e|
    if (e.path =~ /strong\[/)
      if not(game_date==nil) and not(game_result==nil) and (game_result.size > 0)
        games << [year,game_date,game_result,nil]
        game_result = nil
        found += 1
      end
      game_date = e.text.strip
#      game_date = e.inner_text.strip
    elsif (e.path =~ /text/)
      begin
        if (game_result == nil)
#          game_result = e.inner_text.strip
          game_result = e.text.strip
          if (game_result.size==0)
            game_result = nil
          end
        else
          if not(e.path =~ /text\(\)\[2\]\z/)
            games << [year,game_date,game_result,nil]
            found += 1
#            game_result = e.inner_text.strip
            game_result = e.text.strip
            if (game_result.size==0)
              game_result = nil
            end
          else
            game_result = nil
          end
        end
      end
    elsif (e.path =~ /div\/a/)
      local_url = e.attribute("href")
      games << [year,game_date,game_result,"#{base}#{local_url}"]
      game_result = nil
      found += 1
    end
  end
  games.close
  print " - found #{found}\n"
end

