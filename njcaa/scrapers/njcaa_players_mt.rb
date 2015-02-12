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

#http://stats.njcaa.org/sports/bsb/2013-14/div1/teams/connorsstatecollege?view=lineup

encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
  }

player_hitting_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[3]/div[2]/table/tr[position()>1 and not(@class="totals")]'

player_extended_hitting_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[3]/div[3]/table/tr[position()>1 and not(@class="totals")]'

player_pitching_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[3]/div[4]/table/tr[position()>1 and not(@class="totals")]'

player_fielding_xpath = '//*[@id="mainbody"]/div[2]/div[2]/div[3]/div[5]/table/tr[position()>1 and not(@class="totals")]'

rosters_xpath = '//*[@id="mainbody"]/div[2]/div[2]/a'

nthreads = 10

base_sleep = 0
sleep_increment = 3
retries = 4

njcaa_roster_files = CSV.open("csv/njcaa_roster_files_mt.csv","w",{:col_sep => "\t"})

njcaa_player_hitting = CSV.open("csv/njcaa_player_hitting_mt.csv","w",{:col_sep => "\t"})

njcaa_player_extended_hitting = CSV.open("csv/njcaa_player_extended_hitting_mt.csv","w",{:col_sep => "\t"})

njcaa_player_pitching = CSV.open("csv/njcaa_player_pitching_mt.csv","w",{:col_sep => "\t"})

njcaa_player_fielding = CSV.open("csv/njcaa_player_fielding_mt.csv","w",{:col_sep => "\t"})

njcaa_schools = CSV.open("csv/njcaa_schools_revised.csv","r",{:col_sep => "\t", :headers => TRUE})

# Headers

njcaa_roster_files << ["year", "division_id", "school_id",
"roster_url", "original_filename", "saved_filename",
"content_disposition", "meta"]

njcaa_player_hitting << ["year", "division_id", "school_id",
"uniform_number", "player_id", "player_name", "player_url",
"class_year", "position",
"g", "ab", "r", "h", "b2b", "b3b", "hr", "rbi", "bb", "k", "sb", "cs",
"avg", "obp", "slg"]

njcaa_player_extended_hitting << ["year", "division_id", "school_id",
"uniform_number", "player_id", "player_name", "player_url",
"class_year", "position",
"g", "hbp", "sf", "sh", "tb", "xbh", "hdp", "go", "fo", "go_fo", "pa"]

njcaa_player_pitching << ["year", "division_id", "school_id",
"uniform_number", "player_id", "player_name", "player_url",
"class_year", "position",
"g", "gs", "w", "l", "sv", "cg", "ip", "h", "r", "er", "b", "k",
"k_g", "hr", "era"]

njcaa_player_fielding << ["year", "division_id", "school_id",
"uniform_number", "player_id", "player_name", "player_url",
"class_year", "position",
"g", "tc", "po", "a", "e", "fpct", "dp", "sba", "rcs",
"rcs_percent", "pb", "ci"]

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

      year = school[0]
      division_id = school[1]
      school_id = school[2]

      # Need to parse year to use as a parameter

#http://stats.njcaa.org/sports/bsb/2013-14/div1/teams/connorsstatecollege?view=lineup
      player_hitting_url = 'http://anonymouse.org/cgi-bin/anon-www.cgi/http://stats.njcaa.org/sports/bsb/2013-14/div%d/teams/%s?view=lineup' % [division_id, school_id]

#      print "Thread #{thread_id}, sleep #{sleep_time} ... "
#      sleep sleep_time

      tries = 0
      begin
        page = Nokogiri::HTML(open(player_hitting_url))
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

      page.xpath(player_hitting_xpath).each do |tr|

        row = [year, division_id, school_id]
        tr.xpath("td").each_with_index do |td,k|

          text = td.text.strip rescue nil

          # Remove non-ASCII characters
          text.encode(Encoding.find('ASCII'), encoding_options) rescue nil
          # Replace double space with single space
          text.gsub!("  "," ")
            
          if (text=="-")
            text=nil
          end

          text = text.to_nil rescue nil

          case
          when (k==1)

            link = td.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text.split("cgi/")[1]
              player_id = link_url.split("/")[-1]
            else
              link_url = nil
              player_id = nil
            end

            row += [player_id, text, link_url]
            
          when not(k==2)

            row += [text]

          end

        end

        njcaa_player_hitting << row

      end

      page.xpath(player_extended_hitting_xpath).each do |tr|

        row = [year, division_id, school_id]
        tr.xpath("td").each_with_index do |td,k|

          text = td.text.strip rescue nil

          # Remove non-ASCII characters
          text.encode(Encoding.find('ASCII'), encoding_options) rescue nil
          # Replace double space with single space
          text.gsub!("  "," ")
            
          if (text=="-")
            text=nil
          end

          text = text.to_nil rescue nil

          case
          when (k==1)

            link = td.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text.split("cgi/")[1]
              player_id = link_url.split("/")[-1]
            else
              link_url = nil
              player_id = nil
            end

            row += [player_id, text, link_url]
            
          when not(k==2)

            row += [text]

          end

        end

        njcaa_player_extended_hitting << row

      end

      page.xpath(player_pitching_xpath).each do |tr|

        row = [year, division_id, school_id]
        tr.xpath("td").each_with_index do |td,k|

          text = td.text.strip rescue nil

          # Remove non-ASCII characters
          text.encode(Encoding.find('ASCII'), encoding_options) rescue nil
          # Replace double space with single space
          text.gsub!("  "," ")
            
          if (text=="-")
            text=nil
          end

          text = text.to_nil rescue nil

          case
          when (k==1)

            link = td.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text.split("cgi/")[1]
              player_id = link_url.split("/")[-1]
            else
              link_url = nil
              player_id = nil
            end

            row += [player_id, text, link_url]
            
          when not(k==2)

            row += [text]

          end

        end

        njcaa_player_pitching << row

      end

      page.xpath(player_fielding_xpath).each do |tr|

        row = [year, division_id, school_id]
        tr.xpath("td").each_with_index do |td,k|

          text = td.text.strip rescue nil

          # Remove non-ASCII characters
          text.encode(Encoding.find('ASCII'), encoding_options) rescue nil
          # Replace double space with single space
          text.gsub!("  "," ")
            
          if (text=="-")
            text=nil
          end

          text = text.to_nil rescue nil

          case
          when (k==1)

            link = td.search("a").first

            if not(link.nil?)
              link_url = link.attributes["href"].text.split("cgi/")[1]
              player_id = link_url.split("/")[-1]
            else
              link_url = nil
              player_id = nil
            end

            row += [player_id, text, link_url]
            
          when not(k==2)

            row += [text]

          end

        end

        njcaa_player_fielding << row

      end

      # Roster files

      page.xpath(rosters_xpath).each do |link|
        extension = link.text.downcase
        link_href = link.attributes["href"]
        relative_url = link.attributes["href"].text.split("../")[1]
        full_url = base_url+"/2013-14/div#{division_id}/"+relative_url
        roster_file = open(link_href)
        roster_cd = roster_file.meta['content-disposition']
        roster_filename = roster_cd.match(/filename=(\"?)(.+)\1/)[2] rescue nil
        filename = "#{school_id}-#{division_id}-#{year}.#{extension}"
        File.write("roster/#{filename}", roster_file.read)
        njcaa_roster_files << [year, division_id, school_id, full_url, roster_filename, filename, roster_cd, roster_file.meta]
      end

    end

  end

end

threads.each(&:join)

njcaa_roster_files.close
njcaa_player_hitting.close
njcaa_player_extended_hitting.close
njcaa_player_pitching.close
njcaa_player_fielding.close
