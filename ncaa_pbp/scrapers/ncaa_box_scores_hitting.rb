#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

year = ARGV[0]
division = ARGV[1]

stat_id = 10780

class String
  def to_nil
    self.empty? ? nil : self
  end
end

base_url = 'http://stats.ncaa.org'
#base_url = 'http://anonymouse.org/cgi-bin/anon-www.cgi/stats.ncaa.org'

box_scores_xpath = '//*[@id="contentArea"]/table[position()>4]/tr[position()>2]'

#'//*[@id="contentArea"]/table[5]/tbody/tr[1]/td'

#periods_xpath = '//table[position()=1 and @class="mytable"]/tr[position()>1]'

nthreads = 10

base_sleep = 0
sleep_increment = 3
retries = 4

ncaa_team_schedules = CSV.open("csv/ncaa_team_schedules_#{year}_#{division}.csv", "r", {:col_sep => "\t", :headers => TRUE})
ncaa_games_box_scores = CSV.open("csv/ncaa_box_scores_hitting_#{year}_#{division}.csv", "w", {:col_sep => "\t"})

# Headers

box_scores_header = [
"game_id", "section_id", "player_id", "player_name", "player_url",
"starter", "position","g", "ab", "r", "h", "d", "t", "tb", "hr",
"rbi", "bb", "hbp", "sf", "sh", "k", "dp", "sb", "cs", "picked"]

ncaa_games_box_scores << box_scores_header

# Get game IDs

game_ids = []
ncaa_team_schedules.each do |game|
  game_ids << game["game_id"]
end

# Pull each game only once
# Modify in-place, so don't chain

game_ids.compact!
game_ids.sort!
game_ids.uniq!

#game_ids = game_ids[0..199]

n = game_ids.size

gpt = (n.to_f/nthreads.to_f).ceil

threads = []

game_ids.each_slice(gpt).with_index do |ids,i|

  threads << Thread.new(ids) do |t_ids|

    found = 0
    n_t = t_ids.size

    t_ids.each_with_index do |game_id,j|

      sleep_time = base_sleep

      game_url = 'http://stats.ncaa.org/game/box_score/%d?year_stat_category_id=%d' % [game_id, stat_id]

#      print "Thread #{thread_id}, sleep #{sleep_time} ... "
#      sleep sleep_time

      tries = 0
      begin
        page = Nokogiri::HTML(agent.get(game_url).body)
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

      print "#{i}, #{game_id} : #{j+1}/#{n_t}; found #{found}/#{n_t}\n"

      page.xpath(box_scores_xpath).each do |row|

        table = row.parent
        section_id = table.parent.xpath('table[position()>1 and @class="mytable"]').index(table)

        player_id = nil
        player_name = nil
        player_url = nil
        starter = nil

        field_values = []
        row.xpath('td').each_with_index do |element,k|
          case k
          when 0
            raw = element.text.strip

            if (raw[0]=="\u00A0")
              starter = false
            else
              starter = true
            end

            #"\u00A0"
            #gsub(/\302\240/,"")
            player_name = element.text.strip.gsub("\u00A0","") rescue nil
            link = element.search("a").first

            if not(link.nil?)

              link_url = link.attributes["href"].text
              parameters = link_url.split("/")[-1]

              # Player ID

              player_id = parameters.split("=")[2]

              # Player URL

              player_url = base_url+link_url

            end
          when 1
            field_values += [element.text.strip]
          else
            field_values += [element.text.strip.to_i]
          end
        end

        ncaa_games_box_scores << [game_id, section_id, player_id, player_name,
                                  player_url, starter] + field_values

      end

    end

  end

end

threads.each(&:join)

#parts.flatten(1).each { |row| ncaa_play_by_play << row }

ncaa_games_box_scores.close
