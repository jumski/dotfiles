runquery() {
  ssh amvp-testing-2-rails psql $2 -Uroot -h agencymvp-testing-2.cufk6hhkeyow.us-west-2.rds.amazonaws.com agencymvp_production < $1;
}
runpreparedquery() {
  sed 's/$1/1/' < $1 | sed "s/\$2/'1 year'/" | ssh amvp-testing-2-rails psql $2 -Uroot -h agencymvp-testing-2.cufk6hhkeyow.us-west-2.rds.amazonaws.com agencymvp_production;
}

# runquery() { time psql $2 -Upostgres agency_mvp_development_latest < $1; }
# runpreparedquery() {
#   sed 's/$1/1/' < $1 | sed "s/\$2/'1 year'/" | time psql $2 -Upostgres agency_mvp_development_latest;
# }

