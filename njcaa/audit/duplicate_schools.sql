select
s1.year,
s1.division_id,
s2.division_id,
s1.school_name
from njcaa.schools s1
join njcaa.schools s2 on
  (s1.school_id,s1.year)=(s2.school_id,s2.year)
where s1.division_id<s2.division_id;
