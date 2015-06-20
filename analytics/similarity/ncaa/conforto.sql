copy
(
select
name,
year,
comp_name,
comp_year,
rank,
d::numeric(4,2)
from
ncaa._weighted_hitter_similarity
where name like '%Conforto%'
) to '/tmp/conforto.csv' csv header;
