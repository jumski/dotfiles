remote_runpsql() {
  ssh -t amvp-testing-2-rails psql $2 -Uroot -h agencymvp-testing-2.cufk6hhkeyow.us-west-2.rds.amazonaws.com agencymvp_production;
}
remote_runquery() {
  ssh amvp-testing-2-rails psql $2 -Uroot -h agencymvp-testing-2.cufk6hhkeyow.us-west-2.rds.amazonaws.com agencymvp_production < $1;
}
remote_runpreparedquery() {
  # -- $1 - organization_id (integer)
  # -- $2 - string used to produce
  # --      (postgres interval string, like '7 days')
  # -- $3 - string used to produce claim_date threshold
  # --      (postgres interval string, like '7 days')
  sed 's/$1/1/' < $1 | \
    sed "s/\$2/'1 year'/" | \
    sed "s/\$3/'1065 days'/" | \
    ssh amvp-testing-2-rails psql $2 -Uroot -h agencymvp-testing-2.cufk6hhkeyow.us-west-2.rds.amazonaws.com agencymvp_production;
}

runquery() { time psql $2 -Upostgres agency_mvp_development_latest < $1; }
runpreparedquery() {
  sed 's/$1/1/' < $1 | \
    sed "s/\$2/'1 year'/" | \
    sed "s/\$3/'1065 days'/" | \
    time psql $2 -Upostgres agency_mvp_development_latest;
}

