# Intro
Dumps rows into the Jiskefet DB.
TODO: Timed queries to measure performance

# Usage
createdb --username postgres jiskefet-test
psql --username postgres -d jiskefet-test -f tables.sql
python hammer.py