#!/usr/bin/env bash

if [[ "$SILENT" -eq 0 ]]; then
  printf "Using %s\n" "$(mysql -V)";
fi

for DATABASE in "${DATABASES[@]}"; do
  ARGS=(-h "$HOST" -u "$USER" -p"$PASSWORD")
  if [[ -n "$PORT" ]]; then ARGS+=(-P "$PORT"); fi
  if [[ "$SILENT" -eq 0 ]]; then
    ARGS+=(-v)
  fi
  mysql "${ARGS[@]}" < ./"${DATABASE}".sql

  if [ "$DATABASE" == tabulation_area ]; then
    DSN="MySQL:${DATABASE},host=${HOST},user=${USER},password=${PASSWORD}"
    if [[ -n "$PORT" ]]; then DSN+=",port=${PORT}"; fi
    OGR2DRIVER=(MySQL "$DSN")
    cd ../ || exit;
    source ./tabulation_area.sh
    cd "$PLATFORM"/tabulation_area || exit;
    mysql "${ARGS[@]}" < ./county.sql
    mysql "${ARGS[@]}" < ./place.sql
    mysql "${ARGS[@]}" < ./us_state.sql
  fi
done