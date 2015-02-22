#!/usr/bin/env ruby

require 'mechanize'
require 'csv'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

rptWeeks = ["1"]
#rptWeeks = Array.new
#rptWeeks[2] = "2"
#rptWeeks[3] = "3"
#rptWeeks[4] = "4"

#category = ["individual","team"]
category = ["individual"]

rptType = ["CSV"]

divs = [1,2,3]

#stats = Array.new
#stats[0] = [200,201,202,203,204,205,206,207,208,209,321,322,338,339,356,411,412,470,483,485,487,488,490,
#            492,494,495,497,499,502,504,505,508]
#stats[1] = [210,211,212,213,323,324,325,326,327,328,425,484,486,489,491,493,496,498,500,501,503,506,509,513]

stats = [495,200,488,205,499,483,505,470,504,485,487,497,502,209,321,492,356,207,494,339,490,208,508]

first_year = 2014
last_year = 2014
#url = "http://www.ncaa.com/stats/baseball/d1"
base = "http://web1.ncaa.org/stats/StatsSrv/rankings"
#?sportCode=MBA&div=1&rptWeeks=17&category=individual&statSeq=504&rptType=CSV&academicYear=2011&doWhat=showrankings

(first_year..last_year).each do |year|
  divs.each do |div|
    category.each do |cat|
      stats.each do |stat|

        p "ncaa_leaders_#{year}_#{div}_#{cat}_#{stat}.csv"

#        url = "#{base}?sportCode=MBA&div=#{div}&rptWeeks=8&category=individual&statSeq=#{stat}&rptType=CSV&academicYear=#{year}&doWhat=showrankings"
        url = "#{base}?sportCode=MBA&div=#{div}&category=individual&statSeq=#{stat}&rptType=CSV&academicYear=#{year}&doWhat=showrankings"

        begin
          page = agent.get(url)
        rescue
          print "  -> error, retrying\n"
          retry
        end

##        ncaa_form = page.forms[1]
#        ncaa_form = page.form('form1')

#        ncaa_form.sportCode = "MBA"
#        ncaa_form.academicYear = year
#        ncaa_form.div = div
#        # Best?
#        ncaa_form.rptWeeks = "8"
#        ncaa_form.category = cat
#        ncaa_form.statSeq = stat
#        ncaa_form.rptType = "CSV"

#        page = agent.submit(ncaa_form)

        b = page.body.lines.to_a

        m = b.inject(0){|i,e| break i if e =~ /\"Rank/; i+1 }

        b = b[m..-1]
        i = b.index("Reclassifying\n")
        if not(i==nil)
          f = File.open("ncaa_leaders_#{year}_#{div}_#{cat}_#{stat}.csv","w")
          f << b[0..i-1].join
          f.close
        else
          j = b.inject(0){|i,e| break i if e == "\n"; i+1 }
          f = File.open("ncaa_leaders_#{year}_#{div}_#{cat}_#{stat}.csv","w")
          f << b[0..j-1].join
          f.close
        end
      end
    end
  end
end
