
begin;

drop schema gametracker cascade;

create schema gametracker;

create table gametracker.previews (
	event_id		integer,
	preview_id		integer,
--	game_date		date,
	game_date		text,
	display			text,
	hcode			text,
	homename		text,
	refresh			text,
	source			text,
	start			text,
	test			text,
	vcode			text,
	visname			text
--	primary key (event_id,preview_id)
);

create table gametracker.games (
	event_id		integer,
	generated		date,
	source			text,
	version			text,
	attend			integer,
--	game_date		date,
	game_date		text,
	dhgame			integer,
	duration		text, -- interval
	gameid			text,
	homeid			text,
	homename		text,
--	leaguegame		boolean,
	leaguegame		text,
	location		text,
	neutralgame		text,
	schedinn		integer,
	schednote		text,
	series			text,
	stadium			text,
	start			text,
	visid			text,
	visname			text,
	batters			text,
	usedh			text
--	usedh			boolean
--	primary key (event_id)
);

create table gametracker.teams (
	event_id		integer,
	team_id			integer,
	code			text,
	conf			text,
	confrecord		text,
	id			text,
	name			text,
	neutralgame		boolean,
	rank			integer,
	record			text,
	vh			text
--	primary key (event_id,team_id)
);

create table gametracker.players (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	atpos			text,
	bats			text,
	bioid			integer,
	bioxml			text,
	class			text,
	code			text,
	gp			integer,
	gs			integer,
	name			text,
	pos			text,
	shortname		text,
	spot			integer,
	sub			integer,
	throws			text,
	uni			integer
--	primary key (event_id,team_id,player_id)
);

create table gametracker.plays (
	event_id		integer,
	format			text,
	number			integer,
	id			text,
	vh			text,
	batprof			text,
	batter			text,
	first			text,
	outs			integer,
	pchprof			text,
	pitcher			text,
	second			text,
	seq			integer,
	third			text,
	narrative		text
--	primary key (event_id,seq)
);

create table gametracker.umpires (
	event_id		integer,
	first			text,
	hp			text,
	second			text,
	third			text
--	primary key (event_id)
);

create table gametracker.notes (
	event_id		integer,
	note_id			integer,
	text			text
--	primary key (event_id,note_id)
);

create table gametracker.player_hitting (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	ab			integer,
	bb			integer,
	cs			integer,
	double			integer,
	fly			integer,
	gdp			integer,
	ground			integer,
	h			integer,
	hbp			integer,
	hitdp			integer,
	hittp			integer,
	hr			integer,
	ibb			integer,
	kl			integer,
	picked			integer,
	r			integer,
	rbi			integer,
	sb			integer,
	sf			integer,
	sh			integer,
	so			integer,
	triple			integer
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_pitching (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	ab			integer,
	appear			integer,
	bb			integer,
	bf			integer,
	bk			integer,
	cbo			integer,
	cg			integer,
	cia			integer,
	double			integer,
	er			integer,
	fly			integer,
	ground			integer,
	gs			integer,
	h			integer,
	hbp			integer,
	hr			integer,
	ibb			integer,
	inheritr		integer,
	inherits		integer,
	ip			text,
	kl			integer,
	loss			text,
	picked			integer,
	pitches			integer,
	r			integer,
	save			integer,
	sfa			integer,
	sha			integer,
	sho			integer,
	so			integer,
	strikes			integer,
	triple			integer,
	win			text,
	wp			integer
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_fielding (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	a			integer,
	ci			integer,
	csb			integer,
	e			integer,
	indp			integer,
	intp			integer,
	pb			integer,
	po			integer,
	sba			integer
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_hsitsummary (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	adv			integer,
	advops			text,
	fly			integer,
	ground			integer,
	leadoff			text,
	lob			integer,
	pinchhit		text,
	rbi2out			integer,
	rbi3rd			text,
	rcherr			integer,
	rchfc			integer,
	vsleft			text,
	w2outs			text,
	wloaded			text,
	wrbiops			text,
	wrunners		text
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_psitsummary (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	fly			integer,
	ground			integer,
	leadoff			text,
	picked			integer,
	pitches			integer,
	strikes			integer,
	tmunearned		integer,
	vsleft			text,
	w2outs			text,
	wrunners		text
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_hitseason (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	ab			integer,
	avg			text,
	bb			integer,
	cs			integer,
	double			integer,
	e			integer,
	h			integer,
	hr			integer,
	leadoff			text,
	loaded			text,
	pinchhit		text,
	r			integer,
	rbi			integer,
	rbi2out			integer,
	rbi3rd			text,
	sb			integer,
	sf			integer,
	sh			integer,
	so			integer,
	triple			integer,
	vsleft			text,
	vsright			text,
	w2outs			text,
	wrbiops			text,
	wrunners		text
--	primary key (event_id,team_id,player_id)
);

create table gametracker.player_pchseason (
	event_id		integer,
	team_id			integer,
	player_id		integer,
	bb			integer,
	bk			integer,
	double			integer,
	er			integer,
	era			text,
	h			integer,
	hbp			integer,
	hr			integer,
	ip			text,
	leadoff			text,
	loss			integer,
	r			integer,
	save			integer,
	so			integer,
	triple			integer,
	vsleft			text,
	vsright			text,
	w2outs			text,
	win			integer,
	wp			integer,
	wrunners		text
--	primary key (event_id,team_id,player_id)
);

create table gametracker.team_starter (
	event_id		integer,
	team_id			integer,
	name			text,
	pos			text,
	spot			integer,
	uni			integer
--	primary key (event_id,team_id,spot)
);

create table gametracker.team_batord (
	event_id		integer,
	team_id			integer,
	name			text,
	pos			text,
	spot			integer,
	uni			integer
--	primary key (event_id,team_id,spot)
);

create table gametracker.team_lineinn (
	event_id		integer,
	team_id			integer,
	errs			integer,
	hits			integer,
	line			text,
	lob			integer,
	runs			integer,
	inn			integer,
	score			text
--	primary key (event_id,team_id,inn)
);

/*
create temporary table games (
       event_id			integer,
       year			integer,
       primary key (event_id)
);

insert into games
(event_id,year)
(select event_id, extract(year from game_date)
 from gametracker.games);

--update games
--set year=2008
--where event_id in (563715,566949,629937,629939);

delete from gametracker.previews
where event_id in
(select event_id from games
 where year=2009);
*/

copy gametracker.previews from '/home/clong/tools/parsers/gametracker/previews.csv'
with delimiter as ',' csv quote as '"';

--update gametracker.previews
--set game_date='2/24/2009'
--where event_id=563715;

--update gametracker.previews
--set game_date='3/22/2009'
--where event_id=566949;

--update gametracker.previews
--set game_date='3/22/2009'
--where event_id=566951;

--update gametracker.previews
--set game_date='2/23/2009'
--where event_id=629937;

--update gametracker.previews
--set game_date='2/26/2009'
--where event_id=629939;

/*
delete from gametracker.games
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.teams
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.players
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.plays
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.umpires
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.notes
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_hitting
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_pitching
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_fielding
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_hsitsummary
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_psitsummary
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_hitseason
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.player_pchseason
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.team_starter
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.team_batord
where event_id in
(select event_id from games
 where year=2009);

delete from gametracker.team_lineinn
where event_id in
(select event_id from games
 where year=2009);
*/

copy gametracker.games from '/home/clong/tools/parsers/gametracker/games.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.teams from '/home/clong/tools/parsers/gametracker/teams.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.players from '/home/clong/tools/parsers/gametracker/players.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.plays from '/home/clong/tools/parsers/gametracker/plays.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.umpires from '/home/clong/tools/parsers/gametracker/umpires.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.notes from '/home/clong/tools/parsers/gametracker/notes.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_hitting from
  '/home/clong/tools/parsers/gametracker/player_hitting.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_pitching from
  '/home/clong/tools/parsers/gametracker/player_pitching.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_fielding from
  '/home/clong/tools/parsers/gametracker/player_fielding.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_hsitsummary from
  '/home/clong/tools/parsers/gametracker/player_hsitsummary.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_psitsummary from
  '/home/clong/tools/parsers/gametracker/player_psitsummary.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_hitseason from
  '/home/clong/tools/parsers/gametracker/player_hitseason.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.player_pchseason from
  '/home/clong/tools/parsers/gametracker/player_pchseason.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.team_starter from
  '/home/clong/tools/parsers/gametracker/team_starter.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.team_batord from '/home/clong/tools/parsers/gametracker/team_batord.csv'
with delimiter as ',' csv quote as '"';

copy gametracker.team_lineinn from '/home/clong/tools/parsers/gametracker/team_lineinn.csv'
with delimiter as ',' csv quote as '"';

commit;
