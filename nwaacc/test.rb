#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"
require 'hpricot'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://www.nwaacc.org/baseball/results.php"
page = agent.get(url).body
page.gsub!("</a><br>","</a></br><br>")
page.gsub!("<br><br>","<br></br><br>")
doc = Hpricot.XML(page)

table = doc/:table

(table/:tr).each do |row|
  (row/:td).each do |cell|
    puts cell.inner_html
  end
end
