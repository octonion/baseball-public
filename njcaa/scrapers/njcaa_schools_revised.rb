#!/usr/bin/ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

njcaa_schools = CSV.open("csv/njcaa_schools_revised.csv","w",{:col_sep => "\t"})

# Header for team file

njcaa_schools << ["year", "division_id", "school_id", "school_name", "school_url"]

schools_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[2]/table/tr/td/a'

# Base URL for relative team links

base_url = 'http://stats.njcaa.org/sports/bsb/' #2012-13/div1/'

years = [2013,2014]
divisions = [1,2,3]

years.product(divisions).each do |year_division|

  year = year_division[0]
  division_id = year_division[1]
  prev_year = year-1
  season = prev_year.to_s+"-"+year.to_s[-2..-1]

  schools_base_url = base_url+"#{season}/div#{division_id}/"

  found_teams = 0

  url = schools_base_url+"index"
  p url

  doc = Nokogiri::HTML(open(url))

  doc.xpath(schools_xpath).each do |school|

    school_url = base_url+school.attributes["href"].text.strip rescue nil
    school_name = school.text.strip
    school_id = school_url.split("/")[-1].split("?")[0].strip rescue nil

    njcaa_schools << [year, division_id, school_id, school_name, school_url]

  end

end
