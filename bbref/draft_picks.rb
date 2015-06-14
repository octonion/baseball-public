#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.baseball-reference.com/draft/index.cgi?draft_type=junreg&query_type=overall_pick"

anony_base = "http://anonymouse.org/cgi-bin/anon-www.cgi/http://www.baseball-reference.com/draft/index.cgi?draft_type=junreg&query_type=overall_pick"

table_xpath = "/html/body/div/div[4]/div[3]/table/tbody/tr"

picks = CSV.open("draft_picks.csv","w")
header = ["overall_pick","year","round","draft_type","fr_rnd","round_pick","team","name","mlb_url","player_id","milb_url","minors_id","position","war","g","ab","hr","ba","ops","g","w","l","era","whip","sv","school_type","school"]

picks << header

(1..2000).each do |pick|

  url = "#{anony_base}&overall_pick=#{pick}"
  print "Pulling draft pick #{pick}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  page.parser.xpath(table_xpath).each do |r|
    row = [pick]
    r.xpath("td").each_with_index do |e,i|
      et = e.text
      et.gsub!(bad,"")
      et.gsub!("(minors)","")
      if (et.size==0)
        row += [nil]
      else
        row += [et]
      end
      if (i==6)
        hrefs = []
        e.xpath("a").each do |a|
          hrefs += [a.text,a.attribute("href").to_s]
        end
        if (hrefs.size==2)
          if (hrefs[0]=="minors")
            minors_id = hrefs[1][/\/minors\/player\.cgi\?id\=[a-z0-9\.\'\_\-]+/]
            minors_id.gsub!("/minors/player.cgi?id=","")
            row += [nil,nil,hrefs[1],minors_id]
#            row += [nil,nil,hrefs[1]]
          else
            player_id = hrefs[1][/\/[a-z0-9\.\'\_]+\.shtml/]
            player_id.gsub!("/","")
            player_id.gsub!(".shtml","")
            row += [hrefs[1],player_id,nil,nil]
          end
        elsif (hrefs.size==0)
          row += [nil,nil,nil,nil]
        else
          player_id = hrefs[1][/\/[a-z0-9\.\'\_]+\.shtml/]
          player_id.gsub!("/","")
          player_id.gsub!(".shtml","")
          minors_id = hrefs[3][/\/minors\/player\.cgi\?id\=[a-z0-9\.\'\_\-]+/]
          minors_id.gsub!("/minors/player.cgi?id=","")
          row += [hrefs[1],player_id,hrefs[3],minors_id]
        end
      end
    end
    found += 1
    picks << row
  end
  print " - found #{found}\n"
  if (found==0)
    exit
  end
end

picks.close
