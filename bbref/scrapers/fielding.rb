#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

reports = ["standard-fielding","appearances-fielding"]

#"specialpos_p-fielding",
#"specialpos_c-fielding","specialpos_1b-fielding",
#"specialpos_2b-fielding","specialpos_3b-fielding",
#"specialpos_ss-fielding","specialpos_lf-fielding",
#"specialpos_cf-fielding","specialpos_rf-fielding",
#"specialpos_of-fielding"

base = "http://www.baseball-reference.com/leagues/MLB"

table_xpath = '//table[@class="sortable  stats_table" and not(@data-freeze)]/tbody/tr'
#table_xpath = "/html/body/div/div[4]/div[5]/div[2]/div[2]/table/tbody/tr"

first_year = 2015
last_year = 2015

reports.each do |report|

  (first_year..last_year).each do |year|

    out = CSV.open("csv/#{report}-#{year}.csv","w")

    url = "#{base}/#{year}-#{report}.shtml"
    print "Baseball Reference #{report} (#{year})"

    begin
      page = agent.get(url)
    rescue
      retry
    end

    found = 0
    page.parser.xpath(table_xpath).each do |r|

      row = []
      r.xpath("td").each_with_index do |e,i|

        et = e.text
        et.gsub!(bad," ")
        if (et.size==0)
          et = nil
        end
        row += [et]

        if ([1].include?(i))
          hrefs = []
          e.xpath("a").each do |a|
            hrefs += [a.text,a.attribute("href").to_s]
          end
          if (hrefs.size==2)
            id = hrefs[1][/\/[a-z0-9\.\'\_]+\.shtml/]
            id.gsub!("/","")
            id.gsub!(".shtml","")
            row += [hrefs[1],id]
          end
        end

      end

      if (row.size > 0)
        found += 1
        out << [year]+row
      end

    end
    
    print " - found #{found}\n"
    out.close
    
  end

end

