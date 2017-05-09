#!/usr/bin/env ruby
# coding: utf-8

require 'csv'

require 'nokogiri'
require 'open-uri'

bad = ' '

weekly = CSV.open("csv/weekly_rankings.tsv","w",{:col_sep => "\t"})

# Header

weekly << ["year", "division_id", "division_text", "ranking_id", "ranking_text"]

url = 'http://web1.ncaa.org/stats/StatsSrv/ranksummary?doWhat=display&sportCode=MBA'

print "\nRetrieving weekly rankings IDs ... "

doc = Nokogiri::HTML(open(url))

xpath = '//*[@id="nav"]/table/tr/td/table/tr'

found = 0
doc.search(xpath).each do |tr|

  d = tr.attributes.first[0] rescue nil

  if (d==nil)
    next
  end

  division_text = d.split("_")[0]
  division_id = division_text.gsub("d","").to_i
  year = d.split("_")[1].to_i

  a = tr.search("td/a").first
  href = a.attributes["href"].value
  ranking_id = href.split(",")[0].split("(")[1].to_i
  ranking_text = a.text.strip

  weekly << [year,division_id,division_text,ranking_id,ranking_text]
  found += 1

end

weekly.close

print "found #{found} weekly rankings\n\n"
