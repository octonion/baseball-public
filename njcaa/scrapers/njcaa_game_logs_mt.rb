#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'csv'

require 'nokogiri'
require 'open-uri'

#require 'awesome_print'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

base_url = 'http://stats.njcaa.org/sports/bsb'

#2013-14/div%d/teams/%s?view=gamelog' % [division_id, school_id]

#http://stats.njcaa.org/sports/bsb/2013-14/div1/teams/tallahasseecommunitycollege?view=gamelog

encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
  }

game_log_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[3]/table/tr[position()>1]'

nthreads = 10

base_sleep = 0
sleep_increment = 3
retries = 4

#http://stats.njcaa.org/sports/bsb/2013-14/div1/teams/tallahasseecommunitycollege?view=gamelog

njcaa_game_logs = CSV.open("csv/njcaa_game_logs_mt.csv","w",{:col_sep => "\t"})

njcaa_schools = CSV.open("csv/njcaa_schools_revised.csv","r",{:col_sep => "\t", :headers => TRUE})

# Headers

njcaa_game_logs << ["year", "division_id", "school_id", "date", "site", "opponent", "outcome", "winning_score", "losing_score", "score", "game_url", "ab", "r", "h", "b2b", "b3b", "hr", "rbi", "bb", "k", "sb", "cs"]

# Get schools

schools = []
njcaa_schools.each do |school|
  if not(school["school_id"]==nil)
    schools << [school["year"],school["division_id"],school["school_id"]]
  end
end

n = schools.size

gpt = (n.to_f/nthreads.to_f).ceil

threads = []

schools.each_slice(gpt).with_index do |schools_slice,i|

  threads << Thread.new(schools_slice) do |t_schools|

    found = 0
    n_t = t_schools.size

    t_schools.each_with_index do |school,j|

      sleep_time = base_sleep

      year = school[0].to_i
      division_id = school[1]
      school_id = school[2]
      prev_year = year-1
      season = prev_year.to_s+"-"+year.to_s[-2..-1]

      # Need to parse year to use as a parameter

      log_url = 'http://anonymouse.org/cgi-bin/anon-www.cgi/http://stats.njcaa.org/sports/bsb/%s/div%d/teams/%s?view=gamelog' % [season, division_id, school_id]
#      log_url = 'http://stats.njcaa.org/sports/bsb/2013-14/div%d/teams/%s?view=gamelog' % [division_id, school_id]

#      print "Thread #{thread_id}, sleep #{sleep_time} ... "
#      sleep sleep_time

      tries = 0
      begin
        page = Nokogiri::HTML(open(log_url))
      rescue
        sleep_time += sleep_increment
#        print "sleep #{sleep_time} ... "
        sleep sleep_time
        tries += 1
        if (tries > retries)
          next
        else
          retry
        end
      end

      sleep_time = base_sleep

      found += 1

      print "#{i}, #{school_id} : #{j+1}/#{n_t}; found #{found}/#{n_t}\n"

      page.xpath(game_log_xpath).each do |tr|

        row = [year, division_id, school_id]
        tr.xpath("td").each_with_index do |td,k|

          text = td.text.strip rescue nil
          # Remove non-ASCII characters
          text.encode(Encoding.find('ASCII'), encoding_options) rescue nil
          # Replace double space with single space
          text.gsub!("  "," ")

          case
          when (k==1)
            if (text.include?("\r"))
              fields = text.split("\r")
              row += [fields[0].strip, fields[1].strip]
            else
              row += ["neutral", text]
            end
          when (k==2)

            if (text=='-')
              text=nil
            end
            
            link = td.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text.split("../")[1]

              link_url = base_url+"/2013-14/div#{division_id}/"+link_url

              #link_url = link.attributes["href"].text
            else
              link_url=nil
            end
              
            if (text==nil)
              outcome=nil
              winning_score=nil
              losing_score=nil
            else
              text.gsub(", "," ")
              fields = text.split(" ") rescue nil
              if (fields[0].include?("-"))
                score_text = fields[0]
                outcome = fields[1].strip[0] rescue nil
              else
                score_text = fields[1]
                outcome = fields[0].strip[0] rescue nil
              end
              scores = score_text.split("-") rescue nil
              score1=scores[0].strip.to_i rescue nil
              score2=scores[1].strip.to_i rescue nil
              winning_score = [score1,score2].max
              losing_score = [score1,score2].min
            end
            row += [outcome, winning_score, losing_score, text, link_url]
          else
            if (text=='-')
              text = nil
            end
            row += [text]
          end

        end

        if (row.size>10)
          njcaa_game_logs << row
        end

      end

    end

  end

end

threads.each(&:join)

njcaa_game_logs.close
