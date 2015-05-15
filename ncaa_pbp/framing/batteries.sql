copy
(
select

pitcher_id,
catcher_id,
count,
sum(balls) as balls,
sum(called_strikes) as called_strikes
from
(
select
p.player_id as pitcher_id,
c.player_id as catcher_id,
ps.pitch_string,
ps.balls::text||'-'||ps.strikes::text as count,
length(ps.pitch_string)-length(replace(ps.pitch_string,'B','')) as balls,
length(ps.pitch_string)-length(replace(ps.pitch_string,'K','')) as called_strikes
from ncaa_pbp.play_by_play pbp
join ncaa_pbp.periods per
  on (per.game_id,per.section_id)=(pbp.game_id,0)
join ncaa_pbp.pitch_strings ps
  on (ps.game_id,ps.period_id,ps.event_id)=
     (pbp.game_id,pbp.period_id,pbp.event_id)
join ncaa_pbp.box_scores_fielding p
  on (p.game_id,p.section_id)=(per.game_id,per.section_id)
join ncaa_pbp.box_scores_fielding c
  on (c.game_id,c.section_id)=(per.game_id,per.section_id)
where
    pbp.team_text is null
and pbp.opponent_text is not null
and p.starter and p.position='P'
and c.starter and c.position='C'

union all

select
p.player_id as pitcher_id,
c.player_id as catcher_id,
ps.pitch_string,
ps.balls::text||'-'||ps.strikes::text as count,
length(ps.pitch_string)-length(replace(ps.pitch_string,'B','')) as balls,
length(ps.pitch_string)-length(replace(ps.pitch_string,'K','')) as called_strikes
from ncaa_pbp.play_by_play pbp
join ncaa_pbp.periods per
  on (per.game_id,per.section_id)=(pbp.game_id,1)
join ncaa_pbp.pitch_strings ps
  on (ps.game_id,ps.period_id,ps.event_id)=
     (pbp.game_id,pbp.period_id,pbp.event_id)
join ncaa_pbp.box_scores_fielding p
  on (p.game_id,p.section_id)=(per.game_id,per.section_id)
join ncaa_pbp.box_scores_fielding c
  on (c.game_id,c.section_id)=(per.game_id,per.section_id)
where
    pbp.team_text is not null
and pbp.opponent_text is null
and p.starter and p.position='P'
and c.starter and c.position='C'
) outcomes
where
    pitcher_id is not null
and catcher_id is not null
and balls is not null
and called_strikes is not null
group by pitcher_id,catcher_id,count
having sum(balls)+sum(called_strikes)>0
) to '/tmp/batteries.csv' csv header;
