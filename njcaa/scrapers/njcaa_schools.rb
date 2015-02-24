#!/usr/bin/ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

# Header for team file

schools_xpath = '/html/body/center/table[2]/tr[2]/td[2]/div/table[1]/tr[3]/td/form/select/option[position()>1]'

# Base URL for relative team links

base_url = 'http://njcaa.org/'

sport_id = 3
gender_id = 'm'
#divisions_seasons = [[1,7], [2,8], [3,9]]

#year = 2012
#divisions_seasons = [[1,1,2012], [2,2,2012], [3,3,2012]]
#year = 2013
#divisions_seasons = [[1,4,2013], [2,5,2013], [3,6,2013]]
#year = 2014
#divisions_seasons = [[1,7,2014], [2,8,2014], [3,9,2014]]
year = 2015
divisions_seasons = [[1,7,2015], [2,8,2015], [3,9,2015]]

njcaa_schools = CSV.open("csv/njcaa_schools_#{year}.csv",
                         "w",{:col_sep => "\t"})

njcaa_schools << ["year", "season_id", "sport_id", "gender_id", "division_id", "school_id", "school_name", "school_url"]

schools_base_url = 'http://njcaa.org/sports_news.cfm'

found_teams = 0

divisions_seasons.each do |division_season|

  division_id = division_season[0]
  season_id = division_season[1]
  #year = division_season[2]

  url = schools_base_url+"?sid=#{season_id}&divid=#{division_id}&gender=#{gender_id}&slid=#{sport_id}"

  doc = Nokogiri::HTML(open(url))

  doc.xpath(schools_xpath).each do |school|

    school_url = school.attributes["value"].text.strip rescue nil
    school_name = school.text.strip
    school_id = school_url.split("/")[-1].strip rescue nil

    njcaa_schools << [year, season_id, sport_id, gender_id, division_id, school_id, school_name, school_url]

  end

end
