#!/usr/bin/ruby

require 'pg'

conn = PG.connect(dbname: 'baseball')

players_sql = "
select
team_id,id,player_name
from ncaa_pbp.team_rosters
where hashed_name is null
;"

rows = conn.exec(players_sql)

conn.prepare('hash','update ncaa_pbp.team_rosters set hashed_name=$1 where (team_id,id)=($2,$3);')

conn.transaction do
  rows.each do |row|
    team_id = row["team_id"]
    id = row["id"]
    name = row["player_name"].downcase.gsub('.','').gsub('\'','')
    name = name.split(/[\s,-]/).reject(&:empty?)
    hashed_name = name.sort.join
    conn.exec_prepared('hash', [hashed_name,team_id,id])
  end

  names_sql = "
select
team_id,player_name
from ncaa_pbp.name_mappings
where hashed_name is null
;"

  rows = conn.exec(names_sql)

  conn.prepare('names','update ncaa_pbp.name_mappings set hashed_name=$1 where (team_id,player_name)=($2,$3);')

  rows.each do |row|
    team_id = row["team_id"]
    player_name = row["player_name"]
    name = row["player_name"].downcase.gsub('.','').gsub('\'','')
    name = name.split(/[\s,-]/).reject(&:empty?)
    hashed_name = name.sort.join
    conn.exec_prepared('names', [hashed_name,team_id,player_name])
  end

end
