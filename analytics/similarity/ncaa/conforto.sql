copy
(
select
name,
year,
comp_name,
comp_year,
rank,
d
from
ncaa._weighted_hitter_similarity
where name like '%Conforto%'
) to '/tmp/conforto.csv' csv header;
