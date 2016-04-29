#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

reports = ["standard-batting", "value-batting", "advanced-batting",
           "win_probability-batting", "ratio-batting",
           "baserunning-batting", "situational-batting",
           "pitches-batting", "cumulative-batting", "neutral-batting"]

base_url = "http://www.baseball-reference.com"

base_batting_url = "http://www.baseball-reference.com/leagues/MLB"

table_xpath = '//table[@class="sortable  stats_table" and not(@data-freeze)]/tbody/tr'

first_year = 2015
last_year = 2015

reports.each do |report|

  (first_year..last_year).each do |year|

    out = CSV.open("csv/#{report}-#{year}.csv", "w", {:col_sep => "\t"})

    url = "#{base_batting_url}/#{year}-#{report}.shtml"

    print "Baseball Reference #{report} (#{year})"

    begin
      page = agent.get(url)
    rescue
      retry
    end

    found = 0
    page.parser.xpath(table_xpath).each do |r|

      row = [year]
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
            hrefs += [a.text,base_url+a.attribute("href").to_s]
          end
          if (hrefs.size==2)
            id = hrefs[1][/\/[a-z0-9\.\'\_]+\.shtml/]
            id.gsub!("/","")
            id.gsub!(".shtml","")
            row += [hrefs[1],id]
          end
        end

      end

      if (row.size > 1 and not(row[1]==nil))
        found += 1
        out << row
      end

    end

    print " - found #{found}\n"
    out.close

  end
  
end

