#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.baseball-reference.com/draft/?draft_type=junreg&query_type=overall_pick"
table_xpath = '//table[@id="draft_stats"]/tbody/tr'
#table_xpath = "/html/body/div/div[4]/div[3]/table/tbody/tr"

picks = CSV.open("csv/draft_picks.csv","w")
header = ["overall_pick","year","round","draft_type","fr_rnd","round_pick",
          "team_name","team_key",
          "signed",
          "player_name","mlb_url","player_id","milb_url","minors_id",
          "position",
          "war",
          "b_g","ab","hr","ba","ops",
          "p_g","w","l","era","whip","sv",
          "school_type","school_name","school_key"]

picks << header

(1..2000).each do |pick|

  url = "#{base}&overall_pick=#{pick}"
  print "Pulling draft pick #{pick}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  page.parser.xpath(table_xpath).each do |r|
    
    row = [pick]
    r.xpath("td|th").each_with_index do |e,i|
      et = e.text
      et.gsub!(bad,"") rescue nil
      et.gsub!("(minors)","") rescue nil
      if (et.size==0)
        row += [nil]
      else
        row += [et]
      end
      case i
      when 5
        href = e.xpath("a").first.attribute("href").to_s rescue nil
        team_key = href.split("&")[0].split("=")[1] rescue nil
        row += [team_key]
      when 7
        hrefs = []
        e.xpath("a").each do |a|
          hrefs += [a.text,a.attribute("href").to_s]
        end
        if (hrefs.size==2)
          if (hrefs[0]=="minors")
            minors_url = hrefs[1]
            minors_id = minors_url.split("=")[1] rescue nil
            row += [ nil, nil, minors_url, minors_id]
#            row += [nil,nil,hrefs[1]]
          else
            player_url = hrefs[1]
            player_id = player_url.split("/")[-1].split(".")[0] rescue nil
            row += [player_url, player_id, nil, nil]
          end
        elsif (hrefs.size==0)
          row += [nil,nil,nil,nil]
        else
          #player_id = hrefs[1][/\/[a-z0-9\.\'\_]+\.shtml/]
          player_url = hrefs[1]
          player_id = player_url.split("/")[-1].split(".")[0] rescue nil
          #player_id.gsub!(".shtml","") rescue nil
          #minors_id = hrefs[3][/\/minors\/player\.cgi\?id\=[a-z0-9\.\'\_\-]+/]
          minors_url = hrefs[3]
          minors_id = minors_url.split("=")[1] rescue nil
          #minors_id.gsub!("/minors/player.cgi?id=","") rescue nil
          row += [player_url, player_id, minors_url, minors_id]
        end
      when 22
        href = e.xpath("a").first.attribute("href").to_s rescue nil
        school_key = href.split("&")[0].split("=")[1] rescue nil
        row += [school_key]
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

