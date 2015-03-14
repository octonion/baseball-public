begin;

drop table if exists ncaa._year_totals;

create table ncaa._year_totals (
       year  		    integer,
       b_ab		    integer,
       b_hits      	    integer,
       b_doubles	    integer,
       b_triples	    integer,
       b_hr		    integer,
       b_bb		    integer,
       b_so		    integer,
       primary key (year)
);

insert into ncaa._year_totals
(year,b_ab,b_hits,b_doubles,b_triples,b_hr,b_bb,b_so)
(
select
ps.year,
sum(ps.b_ab),
sum(ps.b_hits),
sum(ps.b_doubles),
sum(ps.b_triples),
sum(ps.b_hr),
sum(ps.b_bb),
sum(ps.b_so)
from ncaa.player_statistics ps
join ncaa.schools_divisions sd
  on (sd.year,sd.school_id)=(ps.year,ps.team_id)
where sd.div_id=1
group by ps.year
);

commit;
