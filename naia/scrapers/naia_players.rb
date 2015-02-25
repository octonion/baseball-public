#!/usr/bin/ruby1.9.1

require "csv"
require "mechanize"
require "hpricot"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base="http://www.dakstats.com/WebSync/Pages/Team/IndividualStats.aspx"

#?association=10&sg=MBA&sea=NAIMBA_2011&team=1643

association="10"
sg="MBA"

overallConf="Overall&nbsp;&nbsp;"

reports = ["ba_stp_b_bat_overall","ba_stp_b_Baserun_overall",
           "ba_stp_f_field_overall","ba_stp_p_pitch_overall",
           "ba_stp_p_pitch_opp","ba_stp_p_pitch_per9"]
#           "99"]

teams = CSV.read("teams.csv")

first_year = 2012
last_year = 2012

(first_year..last_year).each do |year|

  sea = "NAIMBA_#{year}"

  reports.each_with_index do |report,i|

    players = CSV.open("naia_players_#{year}_#{i}.csv","w")

    teams.each do |team|

      team_name = team[0]
      team_id = team[5]

      print "#{year}/#{team_name} (#{report})\n"
      url = "#{base}?association=#{association}&sg=#{sg}&sea=#{sea}&overallConf=#{overallConf}&reportName=#{report}&team=#{team_id}"

      begin
        page = agent.get(url)
      rescue
        print page
        print "Error: Retrying\n"
        retry
      end

      page.parser.xpath("//table[@class='gridViewReportBuilderWide']/tr").each do |row|
        # Header?
        if (row.path =~ /\/tr\[1\]\z/)
          next
        end
        r = [team_name,team_id,year]
        row.xpath("td").each_with_index do |d,i|
          if (i==0)
            player_href = d.inner_html.strip
            player_id = player_href[/(plr=\d+)/][/(\d+)/]
            r += [d.text.strip,d.inner_html.strip,player_id]
          else
            r += [d.text.strip]
          end
        end
        players << r
        players.flush
      end
    end
    players.close
  end
end
