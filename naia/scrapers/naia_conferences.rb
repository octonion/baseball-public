#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = 'http://www.dakstats.com/WebSync/Pages/MultiTeam/Division.aspx?association=10&sg=MBA&division=NAIMBA1'

#'&sea=NAIMBA_2014'
path = '//*[(@id = "ctl00_websyncContentPlaceHolder_conferenceDataList")]//a'

first_year = 2015
last_year = 2015

conference_header = ["conference_id", "year", "conference_name"]

(first_year..last_year).each do |year|

  conferences = CSV.open("csv/naia_conferences_#{year}.csv", "w")
  conferences << conference_header

  url = base_url+"&sea=NAIMBA_#{year}"

  begin
    page = agent.get(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  page.parser.xpath(path).each do |a|
    href = a.attribute("href")
    conferences << [a.attribute("href").text.split("=")[-1], year, a.text.strip]
  end

  conferences.close

end



