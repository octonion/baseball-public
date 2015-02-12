#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "csv"
require "mechanize"
require "nokogiri"
require "open-uri"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

data = []

CSV.open("teams.csv").each do |team|

  team_name = team[0]
  if not(team[1]=="html")
    next
  end
  p team_name

  url = team[2]
  #page = agent.get(url)

  begin
    page = Nokogiri::HTML(open(url)) #   page = agent.get(url)
  rescue
    print "Error: Retrying\n"
    retry
  end

  page.css("table").each_with_index do |table,i|

    #if not([1,2,3,4,5].include?(i))
    #  next
    #end

    out = CSV.open("table_#{i}.csv","a")

    table.css("tr").each do |row|

      r = [team_name]
      row.xpath("td").each do |d|
        l = d.text.delete("^\u{0000}-\u{007F}")
        r << l.strip
      end
      if not((r[1] =~ /^-*$/) or (r[1] == "Player")) then
        out << r
      end
    end

    out.close

  end

end
