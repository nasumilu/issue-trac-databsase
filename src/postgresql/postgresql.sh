#!/usr/bin/env bash


if [[ "$SILENT" -eq 0 ]]; then
  printf "Using %s\n" "$(psql -V)";
fi

export PGPASSWORD="$PASSWORD"
for DATABASE in "${DATABASES[@]}"; do
  ARGS=(-h "$HOST" -U "$USER" -d "$DATABASE")
  if [[ -n "$PORT" ]]; then ARGS+=(-p "$PORT"); fi
  if [[ "$SILENT" -eq 1 ]]; then
    ARGS+=(-q)
  fi
  psql "${ARGS[@]}" -f ./"${DATABASE}".sql

  if [ "$DATABASE" == tabulation_area ]; then
    DSN="PG:dbname=${DATABASE} host=${HOST} user=${USER} password=${PASSWORD}"
    if [[ -n "$PORT" ]]; then DSN+=" port=${PORT}"; fi
    OGR2DRIVER=(PostgreSQL "$DSN")
    cd ../ || exit;
    source ./tabulation_area.sh
    cd "$PLATFORM"/tabulation_area || exit;
    psql "${ARGS[@]}" -f ./post-setup.sql
  fi
done
unset PGPASSWORD