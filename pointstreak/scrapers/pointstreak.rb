#!/usr/bin/ruby

require "mechanize"

agent = Mechanize.new
agent.user_agent = "Mozilla/5.0"

first = 29000
last = 35000

base = "http://www.pointstreak.com/baseball/flashapp/getlivegamedata.php"

found = 0

(first..last).each do |id|

  url = "#{base}?gameid=#{id}"

  begin
    page = agent.get(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  if (page.body.size<400)
    next
  end

  found += 1

  print "found id = #{id}, games = #{found}\n"

  file = File.open("XML/#{id}.xml","w")
  file << page.body
  file.close

end
