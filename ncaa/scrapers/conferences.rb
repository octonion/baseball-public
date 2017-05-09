#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'
agent.robots = false

bad = ' '

weekly = CSV.open("csv/weekly_rankings.tsv",
                  "r",
                  {:col_sep => "\t",
                   :headers => true})
conferences = CSV.open("csv/conferences.tsv","w",{:col_sep => "\t"})

conferences << ["year", "division_id", "ranking_id",
                "conference_key"]

teams = CSV.open("csv/conferences_teams.tsv","w",{:col_sep => "\t"})

teams << ["year", "division_id", "ranking_id", "conference_key",
          "conference_id", "team_id", "team_name"]

conference_xpath = '//*[@id="tabs-2"]/table/tr/td/table/tr/td/a'
ct_xpath = '//*[@id="tabs-2"]/table/tr/td/div'

base_url = 'https://web1.ncaa.org/stats/StatsSrv/ranksummary?regionIdx=&conferenceIdx=&schoolIdx=&confId=&orgId=&regionId=&userCustomId=&ncaaCustomId=&rankSummaryType=&'
#division=1&sportCode=MBA&academicYear=2017&doWhat=listSchools&rankSeq=17777'

root_url = 'http://web1.ncaa.org/stats/StatsSrv/ranksummary?regionIdx=&conferenceIdx=&schoolIdx=&confId=&orgId=&regionId=&userCustomId=&ncaaCustomId=&rankSummaryType=&sportCode=MBA'

page = agent.get(root_url)

pulled = []
weekly.each do |week|

  year = week["year"]
  div = week["division_id"]
  rid = week["ranking_id"]
  if (pulled.include?([year,div]))
    next
  end
  pulled << [year,div]

  found = 0
  print "\nRetrieving conferences for #{year}/D#{div} ... "

  url = base_url+"division=#{div}&sportCode=MBA&academicYear=#{year}&doWhat=listSchools&rankSeq=#{rid}"

  page = agent.get(url).parser

begin  
  page.search(conference_xpath).each do |a|

    conference_js = a.attributes["href"].value
    conference_text = conference_js.split("('")[1].split("')")[0]
    conferences << [year, div, rid, conference_text]
    
    found += 1
    
  end
  print "found #{found} conferences\n"
end

  page.search(ct_xpath).each do |ct|
    conference_key = ct.attributes["id"].value
    conference_id = nil
    ct.search("a").each_with_index do |team,i|
      href = team.attributes["href"].value
      if (i==0)
        conference_id = href.split("(")[1].split(")")[0].to_i
      else
        team_id = href.split("(")[1].split(")")[0].to_i
        team_name = team.inner_text
        teams << [year, div, rid, conference_key, conference_id,
                  team_id, team_name]
      end
    end
  end
  
end

conferences.close
teams.close
