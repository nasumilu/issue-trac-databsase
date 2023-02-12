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

# download features and import us states and county into database
DOWNLOAD_URLS=(
  "https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/STATE/tl_${TIGER_YEAR}_us_state.zip"
  "https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/COUNTY/tl_${TIGER_YEAR}_us_county.zip"
)
TABLE_NAMES=(us_state county)
OGR2OPTIONS=(-overwrite)
UNZIP_OPTIONS=(-qq)
CURL_OPTIONS=(-s)
if [[ "$SILENT" -eq 0 ]]; then
  OGR2OPTIONS+=(-progress)
  UNZIP_OPTIONS=()
  CURL_OPTIONS=()
fi

for i in "${!DOWNLOAD_URLS[@]}"; do
  DOWNLOAD_FILE=$(mktemp --dry-run)
  curl "${CURL_OPTIONS[@]}" --output "$DOWNLOAD_FILE" "${DOWNLOAD_URLS[i]}"
  UNZIP_DIR=$(mktemp --directory --dry-run)
  unzip "${UNZIP_OPTIONS[@]}" "${DOWNLOAD_FILE}" -d "$UNZIP_DIR"
  SHP_FILE=$(ls "$UNZIP_DIR"/*.shp)
  ogr2ogr "${OGR2OPTIONS[@]}" -f "${OGR2DRIVER[@]}" "$SHP_FILE" -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=shape -lco FID=id -nln "${TABLE_NAMES[i]}"
  rm -f "$DOWNLOAD_FILE"
  rm -rf "$UNZIP_DIR"
done

# The file ids
FILE_IDS=(01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24  25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 60 66 69 72 78)

for i in "${!FILE_IDS[@]}"; do
  DOWNLOAD_URL="https://www2.census.gov/geo/tiger/TIGER${TIGER_YEAR}/PLACE/tl_${TIGER_YEAR}_${FILE_IDS[i]}_place.zip"
  DOWNLOAD_FILE=$(mktemp --dry-run)
  curl --output "$DOWNLOAD_FILE" "$DOWNLOAD_URL"
  UNZIP_DIR=$(mktemp --directory --dry-run)
  unzip "${DOWNLOAD_FILE}" -d "$UNZIP_DIR"
  SHP_FILE=$(ls "${UNZIP_DIR}"/*.shp)
  ogr2ogr "${OGR2OPTIONS[@]}" -f "${OGR2DRIVER[@]}" "$SHP_FILE" -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=shape -lco FID=id -nln place
  rm -f "$DOWNLOAD_FILE"
  rm -rf "$UNZIP_DIR"
done