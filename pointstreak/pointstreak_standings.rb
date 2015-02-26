#!/usr/bin/ruby

require "csv"
require "hpricot"
require "rest-open-uri"

agent = "Mozilla/5.0"
base = "http://www.pointstreak.com/baseball/standings.html"

leagueid=166
seasonid=239

found = 0

header = ["division_id","division","team_id","team","W","L","PTS",
          "STREAK","LAST 10"]

standings = CSV.open("pointstreak_standings.csv","w")
standings << header

print "\nPulling Pointstreak standings, League #{leagueid}\n"

body = "leagueid=#{leagueid}&seasonid=#{seasonid}"
url = "#{base}?#{body}"

begin
  @response = open(url, 'User-Agent' => agent,
                   :method => :post,
                   :body => body).read
rescue
  print "Error: Retrying\n"
  retry
end

html = @response

doc = Hpricot(html)

doc.search("table").each do |table|
  table.search("tr").each do |tr|
    a = []
    tr.search("th").each do |th|
      division = th.inner_text
      division_html = th.inner_html
      a = [division,division_html]
    end
    t = a
    tr.search("td").each do |e|
      c = e.inner_html
      c.gsub!(/\n/,'')
      c.gsub!(/\r/,'')
      c.gsub!(/\t/,'')
      c.strip!
      t = t + [c]
    end
    
  end
end

standings.close
