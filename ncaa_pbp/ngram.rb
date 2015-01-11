#!/usr/bin/env ruby

require 'csv'

plays = CSV.open("csv/ncaa_games_play_by_play_2014_1.csv", "r",
                 {:col_sep => "\t", :headers => TRUE})

plays.each do |play|
  text = play["team_text"] || play["opponent_text"]
  if (text[0..2]=="R: ")
    next
  end
  if (text.include?(";"))
    next
  end
  if (text.include?(","))
    next
  end
  grams = text.split(" ")
  if !(grams[0]==grams[0].upcase)
    next
  end
  event = text[/([ a-z0-9]+)/,1]
  if (event==nil)
    next
  end
  es = event.strip
  if (es=="")
    next
  end
  p es
end
