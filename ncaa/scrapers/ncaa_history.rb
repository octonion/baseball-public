#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

# Needed for referer

nbsp = Nokogiri::HTML("&nbsp;").text

url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
agent.get(url)

schools = CSV.read("csv/ncaa_schools.csv")

nicknames = CSV.open("csv/ncaa_nicknames.csv","w")
colors = CSV.open("csv/ncaa_colors.csv","w")
locations = CSV.open("csv/ncaa_locations.csv","w")
history = CSV.open("csv/ncaa_history.csv","w")

team_count = 0
season_count = 0

year = 2017

schools.each do |school|
  school_id = school[0]
  school_name = school[1]
  print "#{school_name} (#{team_count}/#{season_count})\n"

  url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
  agent.post(url, {
               "academicYear" => "#{year}",
               "orgId" => school_id,
               "sportCode" => "MBA",
               "playerId" => "-100",
               "coachId" => "-100",
               "division" => "1"
             })

  url = "http://web1.ncaa.org/stats/StatsSrv/careerteamwinloss"
  begin
    page = agent.post(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  team_count += 1

  # Nickname
  page.parser.xpath("/html/body/form/table[2]/tr/td/table/tr[3]").each do |row|
    r = []
    row.xpath("td").each do |d|
      r += [d.text.gsub(nbsp," ").strip]
    end
    nicknames << [school_name,school_id]+r[1..-1] #+[row.path]
  end

  # School colors
  page.parser.xpath("/html/body/form/table[2]/tr/td/table/tr[4]").each do |row|
    r = []
    row.xpath("td").each do |d|
      r += [d.text.gsub(nbsp," ").strip]
    end
    colors << [school_name,school_id]+r[1..-1]
  end

  # Location
  page.parser.xpath("/html/body/form/table[2]/tr/td/table/tr[5]").each do |row|
    r = []
    row.xpath("td").each do |d|
      r += [d.text.gsub(nbsp," ").strip]
    end
    locations << [school_name,school_id]+r[1..-1]
  end

  page.parser.xpath("/html/body/form/table[3]/tr").each do |row|
    if (row.path =~ /\/tr\z/) or (row.path =~ /\/tr\[1\]\z/)
      next
    end
    r = []
    row.xpath("td").each do |d|
      r += [d.text.gsub(nbsp," ").strip]
    end
    season_count += 1
    history << [school_name,school_id]+r
  end

  nicknames.flush
  colors.flush
  locations.flush
  history.flush

end

nicknames.close
colors.close
locations.close
history.close
