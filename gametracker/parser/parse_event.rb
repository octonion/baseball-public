#!/usr/bin/env ruby

require "csv"
require "rexml/document"

include REXML

games_file = CSV.open("games.csv","w")
plays_file =  CSV.open("plays.csv","w")

umpires_file = CSV.open("umpires.csv","w")
notes_file = CSV.open("notes.csv","w")

previews_file =  CSV.open("previews.csv","w")

players_file =  CSV.open("players.csv","w")

player_hitting_file =  CSV.open("player_hitting.csv","w")
player_pitching_file =  CSV.open("player_pitching.csv","w")
player_fielding_file =  CSV.open("player_fielding.csv","w")

player_hitseason_file =  CSV.open("player_hitseason.csv","w")
player_pchseason_file =  CSV.open("player_pchseason.csv","w")

player_hsitsummary_file =  CSV.open("player_hsitsummary.csv","w")
player_psitsummary_file =  CSV.open("player_psitsummary.csv","w")

teams_file =  CSV.open("teams.csv","w")

team_totals_hitting_file =  CSV.open("team_totals_hitting.csv","w")
team_totals_pitching_file =  CSV.open("team_totals_pitching.csv","w")
team_totals_fielding_file =  CSV.open("team_totals_fielding.csv","w")
team_totals_hsitsummary_file =  CSV.open("team_totals_hsitsummary.csv","w")
team_totals_psitsummary_file =  CSV.open("team_totals_psitsummary.csv","w")

team_lineinn_file =  CSV.open("team_lineinn.csv","w")
team_starter_file =  CSV.open("team_starter.csv","w")
team_batord_file =  CSV.open("team_batord.csv","w")

$*.each do |file|
      
  file_name = File.basename(file)
#  print "Parsing #{file_name} ...\n"

  if (File.size(file)<1000)
    print "  #{file_name} is too short\n"
    next
  end
      
  xml_file = Document.new(File.open(file)).root
#  puts xml_file.elements.to_a

  $game = Array.new

  xml_file.elements.each("/bsgame") do |game|

    event_id = game.attributes["event_id"]
    print "Found #{event_id} - parsing.\n"

    game_a = ["event_id","generated","source","version"]

    game_a.each do |a|
      $game << game.attributes[a]
    end

    $venue = Array.new
    
    game.elements.each("venue") do |venue|
      
     venue_a = ["attend","date","dhgame","duration","gameid","homeid",
                "homename","leaguegame","location","neutralgame",
                "schedinn","schednote","series","stadium","start",
                "visid","visname"]

      venue_a.each do |a|
        $venue << venue.attributes[a]
      end
      
      $rules = Array.new
      
      venue.elements.each("rules") do |rules|

        rules_a = ["batters","usedh"]

        rules_a.each do |a|
          $rules << rules.attributes[a]
        end
        
      end #rules

      $umpires = Array.new

      venue.elements.each("umpires") do |umpire|

        umpire_a = ["first","hp","second","third"]

        $umpires << event_id

        umpire_a.each do |a|
          $umpires << umpire.attributes[a]
        end

      end #umpires

      umpires_file << $umpires

      note_id = 0

      venue.elements.each("notes") do |notes|

        notes.elements.each("note") do |note|

          note_a = ["text"]

          $note = Array.new

          $note << event_id
          $note << note_id

          note_a.each do |a|
            $note << note.attributes[a]
          end

          notes_file << $note

          note_id += 1

        end #note

      end #notes
      
    end #venue

    game.elements.each("gametrackerpreview") do |gametrackerpreview|

      # gametrackerpreview
      #   preview
      # end

      preview_id = 0
    
      gametrackerpreview.elements.each("preview") do |preview|

        preview_a = ["date","display","hcode","homename","refresh","source",
                     "start","test","vcode","visname"]

        $preview = Array.new

        $preview << event_id
        $preview << preview_id

        preview_a.each do |a|
          $preview << preview.attributes[a]
        end

        previews_file << $preview

        preview_id += 1
        
      end #preview

    end #gametrackerpreview
    
    $teams = Array.new
    
    team_id = 0

    # team

    game.elements.each("team") do |team|

      team_a = ["code","conf","confrecord","id","name","neutralgame","rank",
                "record","vh"]

      $team = Array.new

      $team << event_id
      $team << team_id

      team_a.each do |a|
        $team << team.attributes[a]
      end
      
#      $teams << $team

      teams_file << $team
      
#      $linescores = Array.new

      # linescore

      team.elements.each("linescore") do |linescore|

        # linescore
        #   lineinn
        # end

        linescore_a = ["errs","hits","line","lob","runs"]
        
        $linescore = Array.new

        $linescore << event_id
        $linescore << team_id

        linescore_a.each do |a|
          $linescore << linescore.attributes[a]
        end
        
        linescore.elements.each("lineinn") do |lineinn|

          lineinn_a = ["inn","score"]
          
          $lineinn = Array.new

          lineinn_a.each do |a|
            $lineinn << lineinn.attributes[a]
          end

          team_lineinn_file << $linescore + $lineinn
          
        end #lineinn
        
      end #linescore
      
      # starters

      team.elements.each("starters") do |starters|

        starters.elements.each("starter") do |starter|

          starter_a = ["name","pos","spot","uni"]

          $starter = Array.new

          $starter << event_id
          $starter << team_id

          starter_a.each do |a|
            $starter << starter.attributes[a]
          end

          team_starter_file << $starter

        end #starter

      end #starters

      # batords

      $batords = Array.new

      team.elements.each("batords") do |batords|

        batords.elements.each("batord") do |batord|

          batord_a = ["name","pos","spot","uni"]

          $batord = Array.new

          $batord << event_id
          $batord << team_id

          batord_a.each do |a|
            $batord << batord.attributes[a]
          end

          team_batord_file << $batord

        end #batord

      end #batords

      # totals
      #   hitting
      #   fielding
      #   hsitsummary
      #   pitching
      #   psitsummary

      team.elements.each("totals") do |totals|

        totals.elements.each("hitting") do |hitting|

          th_a = ["ab","bb","cs","double","errs","fly","gdp","ground","h","hbp",
                  "hitdp","hittp","hits","hr","ibb","kl","line","lob","picked",
                  "r","rchci","rbi","runs","sb","sf","sh","so","triple"]

          $hitting = Array.new

          $hitting << event_id
          $hitting << team_id

          th_a.each do |a|
            $hitting << hitting.attributes[a]
          end

          team_totals_hitting_file << $hitting

#          p $hitting

        end #hitting

        totals.elements.each("pitching") do |pitching|

          th_a = ["ab","bb","bf","bk","cia","double","er","errs","fly","ground","h",
                  "hbp","hits","hr","ibb","ip","kl","line","lob","picked","r","runs",
                  "sfa","sha","sho","so","teamue","triple","wp"]

          $pitching = Array.new

          $pitching << event_id
          $pitching << team_id

          th_a.each do |a|
            $pitching << pitching.attributes[a]
          end

          team_totals_pitching_file << $pitching

#          p $pitching

        end #pitching

        totals.elements.each("fielding") do |fielding|

          tf_a = ["a","ci","csb","e","errs","hits","indp","intp","line","lob","pb","po","runs","sba"]

          $fielding = Array.new

          $fielding << event_id
          $fielding << team_id

          tf_a.each do |a|
            $fielding << fielding.attributes[a]
          end

          team_totals_fielding_file << $fielding

#          p $fielding

        end #fielding

        totals.elements.each("hsitsummary") do |hsitsummary|

          thsit_a = ["adv","advops","errs","fly","ground","hits","leadoff","line","lob","pinchhit",
                     "rbi-2out","rbi3rd","rcherr","rchfc","runs","vsleft","w2outs","wloaded","wrbiops",
                     "wrunners"]

          $hsitsummary = Array.new

          $hsitsummary << event_id
          $hsitsummary << team_id

          thsit_a.each do |a|
            $hsitsummary << hsitsummary.attributes[a]
          end

          team_totals_hsitsummary_file << $hsitsummary

#          p $hsitsummary

        end #hsitsummary

        totals.elements.each("psitsummary") do |psitsummary|

          tpsit_a = ["errs","fly","ground","hits","leadoff","line","lob","picked","pitches","runs",
                     "strikes","tmunearned","vsleft","w2outs","wrunners"]

          $psitsummary = Array.new

          $psitsummary << event_id
          $psitsummary << team_id

          tpsit_a.each do |a|
            $psitsummary << psitsummary.attributes[a]
          end

          team_totals_psitsummary_file << $hsitsummary

#          p $psitsummary

        end #psitsummary

      end #totals

      #   hitting
      #   fielding
      #   hsitsummary
      #   pitching
      #   psitsummary

      # player

      player_id = 0

      team.elements.each("player") do |player|

        p_a = ["atpos","bats","bioid","bioxml","class","code","gp","gs",
               "name","pos","shortname","spot","sub","throws","uni"]

        $player = Array.new

        $player << event_id
        $player << team_id
        $player << player_id

        p_a.each do |a|
          $player << player.attributes[a]
        end

        players_file << $player

        # p $player

        player.elements.each("hitting") do |hitting|

          if (hitting.attributes.size==0)
            next
          end

          ph_a = ["ab","bb","cs","double","fly","gdp","ground","h","hbp",
                  "hitdp","hittp","hr","ibb","kl","picked","r","rbi",
                  "sb","sf","sh","so","triple"]

          $hitting = Array.new

          $hitting << event_id
          $hitting << team_id
          $hitting << player_id

          ph_a.each do |a|
            $hitting << hitting.attributes[a]
          end

          player_hitting_file << $hitting

#          p $hitting

        end #hitting

        player.elements.each("pitching") do |pitching|

          if (pitching.attributes.size==0)
            next
          end

          pp_a = ["ab","appear","bb","bf","bk","cbo","cg","cia",
                  "double","er","fly","ground","gs","h","hbp",
                  "hr","ibb","inheritr","inherits","ip","kl",
                  "loss","picked","pitches","r","save","sfa",
                  "sha","sho","so","strikes","triple","win","wp"]

          $pitching = Array.new

          $pitching << event_id
          $pitching << team_id
          $pitching << player_id

          pp_a.each do |a|
            $pitching << pitching.attributes[a]
          end

          player_pitching_file << $pitching

#          p $pitching

        end #pitching

        player.elements.each("fielding") do |fielding|

          if (fielding.attributes.size==0)
            next
          end

          pf_a = ["a","ci","csb","e","indp","intp","pb","po","sba"]

          $fielding = Array.new

          $fielding << event_id
          $fielding << team_id
          $fielding << player_id

          pf_a.each do |a|
            $fielding << fielding.attributes[a]
          end

          player_fielding_file << $fielding

#          p $fielding

        end #fielding

        player.elements.each("hitseason") do |hitseason|

          if (hitseason.attributes.size==0)
            next
          end

          phs_a = ["ab","avg","bb","cs","double","e","h","hr","leadoff",
                   "loaded","pinchhit","r","rbi","rbi-2out","rbi3rd","sb",
                   "sf","sh","so","triple","vsleft","vsright","w2outs",
                   "wrbiops","wrunners"]

          $hitseason = Array.new

          $hitseason << event_id
          $hitseason << team_id
          $hitseason << player_id

          phs_a.each do |a|
            $hitseason << hitseason.attributes[a]
          end

          player_hitseason_file << $hitseason

#          p $hitseason

        end #hitseason

        player.elements.each("pchseason") do |pchseason|

          if (pchseason.attributes.size==0)
            next
          end

          pps_a = ["bb","bk","double","er","era","h","hbp","hr",
                   "ip","leadoff","loss","r","save","so","triple",
                   "vsleft","vsright","w2outs","win","wp","wrunners"]

          $pchseason = Array.new

          $pchseason << event_id
          $pchseason << team_id
          $pchseason << player_id

          pps_a.each do |a|
            $pchseason << pchseason.attributes[a]
          end

          player_pchseason_file << $pchseason

#          p $pchseason

        end #pchseason

        player.elements.each("hsitsummary") do |hsitsummary|

          if (hsitsummary.attributes.size==0)
            next
          end

          phsit_a = ["adv","advops","fly","ground","leadoff",
                     "lob","pinchhit","rbi-2out","rbi3rd","rcherr",
                     "rchfc","vsleft","w2outs","wloaded","wrbiops",
                     "wrunners"]

          $hsitsummary = Array.new

          $hsitsummary << event_id
          $hsitsummary << team_id
          $hsitsummary << player_id

          phsit_a.each do |a|
            $hsitsummary << hsitsummary.attributes[a]
          end

          player_hsitsummary_file << $hsitsummary

#          p $hsitsummary

        end #hsitsummary

        player.elements.each("psitsummary") do |psitsummary|

          if (psitsummary.attributes.size==0)
            next
          end

          ppsit_a = ["fly","ground","leadoff","picked","pitches",
                     "strikes","tmunearned","vsleft","w2outs","wrunners"]

          $psitsummary = Array.new

          $psitsummary << event_id
          $psitsummary << team_id
          $psitsummary << player_id

          ppsit_a.each do |a|
            $psitsummary << psitsummary.attributes[a]
          end

          player_psitsummary_file << $psitsummary

#          p $psitsummary

        end #psitsummary

        player_id += 1

      end #player

      team_id += 1
      
    end #team
    
#    p $teams
    
    #   team
    #     linescore
    #       lineinn
    #     starters
    #       starter
    #     batords
    #       batord
    #     totals
    #       hitting
    #       fielding
    #       hsitsummary
    #       pitching
    #       psitsummary
    
    games_file << $game + $venue + $rules
    
    $plays = Array.new

    $plays << event_id
    
    game.elements.each("plays") do |plays|

      plays_a = ["format"]
      
      $plays << plays.attributes["format"]
      
      plays.elements.each("inning") do |inning|

        inn_a = ["number"]
        
        $inning = Array.new
        
        $inning << inning.attributes["number"]
        
        inning.elements.each("batting") do |batting|

          bat_a = ["id","vh"]
          
          $batting = Array.new

          bat_a.each do |a|
            $batting << batting.attributes[a]
          end

          batting.elements.each("play") do |play|
            
            $play = Array.new

            play_a = ["batprof","batter","first","outs","pchprof",
                      "pitcher","second","seq","third"]

            play_a.each do |a|
              $play << play.attributes[a]
            end

            $narrative = Array.new
            
            play.elements.each("narrative") do |narrative|
              
              $narrative << narrative.attributes["text"]
              
            end #narrative
            
            if ($narrative.size==0)
              $narrative=[nil]*1
            end

=begin            
            $batter = Array.new
            
            play.elements.each("batter") do |batter|
              
              $batter << batter.attributes["action"]
              $batter << batter.attributes["ab"]
              $batter << batter.attributes["h"]
              $batter << batter.attributes["double"]
              $batter << batter.attributes["triple"]
              $batter << batter.attributes["hr"]
              $batter << batter.attributes["k"]
              $batter << batter.attributes["kl"]
              $batter << batter.attributes["bb"]
              $batter << batter.attributes["ibb"]
              $batter << batter.attributes["hbp"]
              $batter << batter.attributes["gndout"]
              $batter << batter.attributes["flyout"]
              
            end #batter
            
            if ($batter.size==0)
              $batter = [nil]*13
            end
            
            $pitcher = Array.new
            
            play.elements.each("pitcher") do |pitcher|
              
              $pitcher << pitcher.attributes["name"]
              $pitcher << pitcher.attributes["bf"]
              $pitcher << pitcher.attributes["ab"]
              $pitcher << pitcher.attributes["h"]
              $pitcher << pitcher.attributes["double"]
              $pitcher << pitcher.attributes["triple"]
              $pitcher << pitcher.attributes["hr"]
              $pitcher << pitcher.attributes["k"]
              $pitcher << pitcher.attributes["kl"]
              $pitcher << pitcher.attributes["bb"]
              $pitcher << pitcher.attributes["ibb"]
              $pitcher << pitcher.attributes["hbp"]
              $pitcher << pitcher.attributes["gndout"]
              $pitcher << pitcher.attributes["flyout"]
              $pitcher << pitcher.attributes["r"]
              $pitcher << pitcher.attributes["er"]
              
            end #pitcher
            
            if ($pitcher.size==0)
              $pitcher = [nil]*64
            elsif ($pitcher.size==16)
              $pitcher += [nil]*48
            elsif ($pitcher.size==32)
              $pitcher += [nil]*32
            elsif ($pitcher.size==48)
              $pitcher += [nil]*16
            end
=end
            
            plays_file << $plays + $inning + $batting + $play + $narrative
            
          end #play
          
        end #batting
        
      end #inning
      
    end #plays
    
  end #game

end

games_file.close
plays_file.close

umpires_file.close
notes_file.close

previews_file.close

players_file.close

player_hitting_file.close
player_pitching_file.close
player_fielding_file.close

player_hitseason_file.close
player_pchseason_file.close

player_hsitsummary_file.close
player_psitsummary_file.close

teams_file.close

team_totals_hitting_file.close
team_totals_pitching_file.close
team_totals_fielding_file.close
team_totals_hsitsummary_file.close
team_totals_psitsummary_file.close

team_lineinn_file.close
team_starter_file.close
team_batord_file.close
