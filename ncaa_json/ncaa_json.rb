#!/usr/bin/env ruby

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

results = CSV.open("games_2015.csv","w")

#divisions = ["d1","d2","d3"]
divisions = ["d1"]

#game_date = Date::strptime(testdate, "%d-%m-%Y")

date_start = Date.new(2015,2,13)
date_end = Date.today

for div_date in divisions.product(Array(date_start..date_end)) do

  division = div_date[0]
  game_date = div_date[1]

  sb_base_url = "http://data.ncaa.com/scoreboard/baseball"
  data_base_url = "http://data.ncaa.com/game/baseball"

  sb_url = "%s/%s/%s/%02d/%02d/scoreboard.html" % [sb_base_url,division,game_date.year,game_date.month,game_date.day]

  tries = 0
  begin
    page = agent.get_file(sb_url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    next
  end

  print "Found scoreboard for #{division} - #{game_date}\n"

  sb_json = JSON.parse(page) rescue nil

  if sb_json==nil
    print " - nil\n"
    next
  end

  sb_json["scoreboard"].each do |day|

    game_date = day["day"]

    day["games"].each_with_index do |game,i|

      game_id = game["id"]

      row = Hash["gameinfo"=>game]

      tab_path = game["tabs"].split("/baseball/")[1]
      url = "#{data_base_url}/#{tab_path}"

      tries = 0
      begin
        page = agent.get_file(url)
      rescue
        print " -> attempt #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      tabs = JSON.parse(page)

      tabs.each do |tab|
        type = tab["type"]

        file_path = tab["file"].split("/baseball/")[1]
        url = "#{data_base_url}/#{file_path}"

        tries = 0
        begin
          page = agent.get_file(url)
        rescue
          print " -> attempt #{tries}\n"
          tries += 1
          retry if (tries<4)
          next
        end

        row[type] = JSON.parse(page)

      end

      gameinfo = row["gameinfo"].to_json
      if (gameinfo=='null')
        gameinfo=nil
      end

      boxscore = row["boxscore"].to_json
      if (boxscore=='null')
        boxscore=nil
      end

      pbp = row["play-by-play"].to_json
      if (pbp=='null')
        pbp=nil
      end

      results << [game_id,
                  game_date,
                  gameinfo,
                  boxscore,
                  pbp]

    end

  end

end

results.close

exit 0
