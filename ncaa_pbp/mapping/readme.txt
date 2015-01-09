# Old file names

#psql baseball -f deduplicate_rosters.sql
#psql baseball -f load_manual_missing.sql
#psql baseball -f create_rails_name_mappings.sql

# Revised file names (for clarity)

psql baseball -f rosters_remove_duplicates.sql

psql baseball -f rosters_manually_load_missing.sql

psql baseball -f rosters_create_name_mappings.sql

./rosters_create_name_hashes.rb

psql baseball -f rosters_manually_update_remaps.sql

# Requires the PostgreSQL Levenshtein functionfound in the contributed
# fuzzystrmatch module

# To install:
# apt-get install postgresql-contrib
# CREATE EXTENSION fuzzystrmatch;

psql baseball -f rosters_compute_levenshtein_distances.sql

