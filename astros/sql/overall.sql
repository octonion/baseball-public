select pitch_type,avg(release_speed::float),avg(release_spin_rate::float),count(*) from kershaw.pitches where release_speed<>'null' and release_spin_rate<>'null' group by pitch_type order by pitch_type asc;