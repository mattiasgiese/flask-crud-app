#!/bin/bash

if [ -n "$DATABASE_URI" ]; then
  # Are we using an external DB?
  if [[ ! "$DATABASE_URI" =~ 'sqlite' ]]; then
    # DATABASE_URI=mysql+pymysql://bookstore:bookstore@database/bookstore
    DB_HOST=`echo $DATABASE_URI | sed -E 's|.*@([a-z]+)/.*|\1|'`
    # Hard coding ports per service here. It's awful but good enough for a demo
    [[ $DATABASE_URI =~ 'mysql' ]] && DB_PORT=3306
    [[ $DATABASE_URI =~ 'postgres' ]] && DB_PORT=5432
    while true; do
      timeout 1 bash -c "cat < /dev/null > /dev/tcp/${DB_HOST}/${DB_PORT}" && break
      echo Waiting for DB instance: $DATABASE_URI
      sleep 5
    done
  fi
fi
