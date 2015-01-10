#!/usr/bin/env ruby

require 'csv'
require 'mechanize'
require 'cgi'

#require 'nokogiri'
#require 'open-uri'

sport_code = "MBA"

root_url = 'http://stats.ncaa.org'

base_url = 'http://stats.ncaa.org/team/inst_team_list'

year_path = '//*[@id="root"]/li[3]/ul/li/a'
division_path = '//*[@id="root"]/li[5]/ul/li/a'
#team_path = '//*[@id="contentArea"]/div[4]/div/table/tr/td[1]/table/tr[1]/td/a'

team_path = '//*[@id="contentArea"]/div[4]/div/table/tr/td/table/tr/td/a'

ncaa_years = CSV.open("csv/ncaa_years.csv","w",{:col_sep => "\t"})
ncaa_years_divisions = CSV.open("csv/ncaa_years_divisions.csv","w",{:col_sep => "\t"})

# Headers

ncaa_years << ["sport_code", "year"]
ncaa_years_divisions << ["sport_code", "year", "division"]

#?sport_code=MBA&academic_year=2014&division=&conf_id=-1&schedule_date=

sport_url = base_url+"?sport_code=#{sport_code}&academic_year=&division=&conf_id=-1&schedule_date="

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

page = agent.get(sport_url)

#years = page.parser.xpath(year_path).map {|x| x.attributes["href"].text[/\d+/].to_i}

found_years = 0
years = []
page.parser.xpath(year_path).each do |child|
  year = child.attributes["href"].text[/\d+/].to_i
  years += [year]
  ncaa_years << [sport_code, year]
  found_years += 1
end

ncaa_years.close

print "\nfound #{found_years} years\n"

years.each do |year|

  sport_year_url = base_url+"?sport_code=#{sport_code}&academic_year=#{year}&division=&conf_id=-1&schedule_date="
  page2 = agent.get(sport_year_url)

  found_divisions = 0
  divisions = []
  page2.parser.xpath(division_path).each do |child|

    division = child.attributes["href"].text[/\d+/].to_i
    divisions += [division]

    ncaa_years_divisions << [sport_code, year, division]
    found_divisions += 1

    ncaa_teams = CSV.open("csv/ncaa_teams_#{year}_#{division}.csv","w",{:col_sep => "\t"})
    ncaa_teams << ["sport_code", "year", "year_id", "division_id",
                   "team_id", "team_name", "team_url"]

    url = base_url+"?sport_code=#{sport_code}&academic_year=#{year}&division=#{division}&conf_id=-1&schedule_date="
    page3 = agent.get(url)

    found_teams = 0
    page3.parser.xpath(team_path).each do |child|

      team_name = child.parent.text.strip

      href = child.attributes["href"].text
      team_url = root_url+href

      year_id = href.split("/")[-1].split("?")[0].to_i

      parameters = CGI::parse(href.split("?")[1])
      team_id = parameters["org_id"][0].to_i

      row = [sport_code, year, year_id, division,
             team_id, team_name, team_url]

      ncaa_teams << row
      found_teams += 1

    end

    ncaa_teams.close
    print "\nfound #{found_teams} teams for #{year}, division #{division}\n"

  end

   print "\nfound #{found_divisions} divisions for #{year}\n"
end

ncaa_years_divisions.close



