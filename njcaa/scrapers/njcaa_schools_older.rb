#!/usr/bin/ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

njcaa_schools = CSV.open("csv/njcaa_schools.csv_older","w",{:col_sep => "\t"})

# Header for team file

njcaa_schools << ["year", "sport_id", "school_id", "school_name", "school_url", "division_id", "division_name"]

#/html/body/center/table[2]/tbody/tr[2]/td[2]/div/table[1]/tbody/tr[3]/td/form/select/option

#schools_xpath = '/html/body/center/table[2]/tbody/tr/td[1]/div[2]/table[2]/tbody/tr/td[1]/table/tbody/tr'

schools_xpath = '/html/body/center/table[2]/tr/td[1]/div[2]/table[2]/tr/td[1]/table/tr'

# Base URL for relative team links

base_url = 'http://njcaa.org/'

sport_id = 3
schools_url = "http://njcaa.org/colleges.cfm?regionId=&sportslid=#{sport_id}&stname=&x=38&y=10"

year = 2014

found_teams = 0

doc = Nokogiri::HTML(open(schools_url))

doc.xpath(schools_xpath).each do |tr|

  row = [year, sport_id]

  tr.xpath("td").each_with_index do |td,i|
    case
    when i==0
      link = td.xpath("a").first
      school_name = td.text.strip
      school_url = (base_url+link.attributes["href"].text.strip) rescue nil
      school_id = school_url.split("=")[1].to_i rescue nil
      row += [school_id, school_name, school_url]
    when i==1
      division_name = td.text.strip
      division = division_name.split(" ")[1]
      division_id = division.size
      row += [division_id, division_name]
    end
  end

  if (row.size>5)
    njcaa_schools << row
  end

end

=begin
  link_url = link.attributes["href"].text

  # Valid team URLs

  if (link_url).include?(valid_url_substring)

    # NCAA year_id

    parameters = link_url.split("/")[-1]
    year_id = parameters.split("?")[0]

    # NCAA team_id

    team_id = parameters.split("=")[1]

    # NCAA team name

    team_name = link.text()

    # NCAA team URL

    team_url = base_url+link_url

    ncaa_teams << [year, year_id, team_id, team_name, team_url]
    found_teams += 1

  end

  ncaa_teams.flush

end

ncaa_teams.close

print "found #{found_teams} teams\n\n"
=end
