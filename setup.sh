#!/usr/bin/env bash

set -a
source <(cat .env.local | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +a

download_urls=(
  "https://www2.census.gov/geo/tiger/TIGER${ISSUE_TRAC_TIGER_YEAR}/STATE/tl_${ISSUE_TRAC_TIGER_YEAR}_us_state.zip"
  "https://www2.census.gov/geo/tiger/TIGER${ISSUE_TRAC_TIGER_YEAR}/COUNTY/tl_${ISSUE_TRAC_TIGER_YEAR}_us_county.zip"
)
table_names=(us_state_staging county_staging)

dns="host=${ISSUE_TRAC_DB_HOST} user=${ISSUE_TRAC_DB_USER} dbname=${ISSUE_TRAC_DB_NAME} password=${ISSUE_TRAC_PWD} port=${ISSUE_TRAC_PORT}"

for i in "${!download_urls[@]}"; do
  download_file=$(mktemp --dry-run)
  curl  "${download_urls[i]}" --output "${download_file}"
  unzip_dir=$(mktemp --directory --dry-run)
  unzip "${download_file}" -d "${unzip_dir}"
  shp_file=$(ls "${unzip_dir}"/*.shp)
  ogr2ogr -progress -overwrite -f PostgreSQL PG:"${dns}" "${shp_file}" -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=shape -lco FID=id -lco SPATIAL_INDEX=GIST -nln "${table_names[i]}" -overwrite
  rm -f "${download_file}"
  rm -rf "${unzip_dir}"
done

file_id=(01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24  25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 60 66 69 72 78)

for i in "${!file_id[@]}"; do
  download_url="https://www2.census.gov/geo/tiger/TIGER${ISSUE_TRAC_TIGER_YEAR}/PLACE/tl_${ISSUE_TRAC_TIGER_YEAR}_${file_id[i]}_place.zip"
  download_file=$(mktemp --dry-run)
  echo "${download_file}"
  curl "${download_url}" --output "${download_file}"
  unzip_dir=$(mktemp --directory --dry-run)
  unzip "${download_file}" -d "${unzip_dir}"
  shp_file=$(ls "${unzip_dir}"/*.shp)
  ogr2ogr -progress -append -f PostgreSQL PG:"${dns}" "${shp_file}" -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=shape -lco FID=id -lco SPATIAL_INDEX=GIST -nln incorporated_place_staging
  rm -f "${download_file}"
  rm -rf "${unzip_dir}"
done