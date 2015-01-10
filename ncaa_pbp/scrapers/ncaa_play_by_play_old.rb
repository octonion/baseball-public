#!/usr/bin/env ruby

require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'

base_sleep = 0
sleep_increment = 3
retries = 4

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

base = "http://stats.ncaa.org/game/play_by_play"

periods = CSV.open("csv/ncaa_games_periods.csv","w")
notes = CSV.open("csv/ncaa_games_notes.csv","w")
info = CSV.open("csv/ncaa_games_info.csv","w")
officials = CSV.open("csv/ncaa_games_officials.csv","w")
pbp = CSV.open("csv/ncaa_games_play_by_play.csv","w")

files =[periods,notes,info,officials,pbp]

data = []

ids = []
CSV.open("csv/ncaa_team_schedules.csv","r",{:col_sep => "\t", :headers => TRUE}).each do |game|
  if not(game[19]==nil)
    game_id = game[19]
    ids << game_id.to_i
  end
end

ids.sort!.uniq!

n = ids.size

found = 0

ids.each_with_index do |game_id,i|

  url = "#{base}/#{game_id}"
  sleep_time = base_sleep

  print "Sleep #{sleep_time} ... "
  sleep sleep_time

  tries = 0

  begin
    page = Nokogiri::HTML(open(url))
  rescue
    sleep_time += sleep_increment
    print "sleep #{sleep_time} ... "
    sleep sleep_time
    tries += 1
    if (tries > retries)
      next
    else
      retry
    end
  end

  found += 1

  print "#{game_id} : #{i+1}/#{n}; found #{found}/#{n}\n"

    page.css("table").each_with_index do |table,i|

      if (i>3)
        if (i%2==0)
          next
        else
          file_id = 4
          period = i/2 - 1
        end
      else
        file_id = i
      end

      table.css("tr").each_with_index do |row,j|

        if (file_id==4)
          r = [game_id,period,j]
        else
          r = [game_id,j]
        end

        row.xpath("td").each_with_index do |d,k|

          l = d.text.delete("^\u{0000}-\u{007F}").strip
          r += [l]

      end

      if (r.size < 7)
        next
      else
        if (r[2].is_a? Integer) and (r[2]>0)

          rr = r[0..3]

          sa = r[4].split(',',2)
          if not(sa==[])
            if (sa[0]==r[4])
              last=nil
            else
              last = sa[0].strip
            end
            if (sa[1]==nil)
              sb = sa[0].split(' ',2)
            else
              sb = sa[1].split(' ',2)
            end
            first = sb[0].strip if sb[0]
            event = sb[1].strip if sb[1]
            rr += [last,first,event]
          else
            rr += [nil,nil,nil]
          end

          sa = r[5].split('-',2)
          rr += [sa[0].strip,sa[1].strip]

          sa = r[6].split(',',2)
          if not(sa==[])
            if (sa[0]==r[6])
              last=nil
            else
              last = sa[0].strip
            end
            if (sa[1]==nil)
              sb = sa[0].split(' ',2)
            else
              sb = sa[1].split(' ',2)
            end
            first = sb[0].strip if sb[0]
            event = sb[1].strip if sb[1]
            rr += [last,first,event]
          else
            rr += [nil,nil,nil]
          end

          files[file_id] << rr

        else
          next
        end
      end
    end

  end

  files.each do |file|
    file.flush
  end

end

files.each do |file|
  file.close
end
