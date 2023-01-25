#!/usr/bin/env bash

#
#    Copyright 2023 Michael Lucas
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#   limitations under the License.
#

psql -f setup.sql

# download features and import us states and county into database
download_urls=(
  "https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/STATE/tl_${TIGER_YEAR}_us_state.zip"
  "https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/COUNTY/tl_${TIGER_YEAR}_us_county.zip"
)
table_names=(us_state county)

dns="host=${PGHOSTADDR} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD} port=${PGPORT}"

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

# The file ids
file_id=(01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24  25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 60 66 69 72 78)

for i in "${!file_id[@]}"; do
  download_url="https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/PLACE/tl_${TIGER_YEAR}_${file_id[i]}_place.zip"
  download_file=$(mktemp --dry-run)
  echo "${download_file}"
  curl "${download_url}" --output "${download_file}"
  unzip_dir=$(mktemp --directory --dry-run)
  unzip "${download_file}" -d "${unzip_dir}"
  shp_file=$(ls "${unzip_dir}"/*.shp)
  ogr2ogr -progress -append -f PostgreSQL PG:"${dns}" "${shp_file}" -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=shape -lco FID=id -lco SPATIAL_INDEX=GIST -nln place
  rm -f "${download_file}"
  rm -rf "${unzip_dir}"
done

psql -f post-setup.sql