begin;

drop table if exists ncaa.player_statistics;

create table ncaa.player_statistics (
        team_name			text,
        team_id				integer,
	year		      		integer,
        player_name	      		text,
        player_id	      		integer,
	class_year	      		text,
	season_year	      		text,
	position	      		text,
	b_games				integer,
	b_ab				integer,
	b_runs				integer,
	b_hits				integer,
	b_avg				numeric(4,3),
	b_doubles			integer,
	b_triples			integer,
	b_hr				integer,
	b_total_bases			integer,
	b_slg				numeric(4,3),
	b_rbi				integer,
	b_sb				integer,
	b_sba				integer,
	b_bb				integer,
	b_so				integer,
	b_hbp				integer,
	b_sac_hits			integer,
	b_sac_flies			integer,
	p_appearances			integer,
	p_games_started			integer,
	p_complete_games		integer,
	p_wins				integer,
	p_losses			integer,
	p_saves				integer,
	p_shutouts			integer,
	p_ip				text,
	p_hits				integer,
	p_runs				integer,
	p_earned_runs			integer,
	p_bb				integer,
	p_so				integer,
	p_era				text
);

copy ncaa.player_statistics from '/tmp/ncaa_player_statistics.csv' with delimiter as '|' csv quote as '"';

commit;
