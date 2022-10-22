#!/bin/bash

set -x
set -e
set -u
set -o pipefail

nome="amministazioni-italiane"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../dati/"$nome"/rawdata
mkdir -p "$folder"/../../dati/"$nome"/processing
mkdir -p "$folder"/../../dati/"$nome"/report
mkdir -p "$folder"/tmp

# cancella file temporanei json
find "$folder"/tmp/ -maxdepth 1 -iname "prov*.json" -type f -delete

# valida tutti i CSV provinciali a partire dallo schema frictionless
find "$folder"/../../dati/amministazioni-italiane/rawdata/ -iname "prov*.csv" -type f -maxdepth 1 -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  name=$(basename "$line" .csv)
  frictionless validate --json "$folder"/../../dati/amministazioni-italiane/risorse/province.yml --basepath "$folder"/../../dati/amministazioni-italiane/rawdata --path "$name".csv >"$folder"/tmp/"$name".json
done

# cancella file temporaneo raccolta errori
if [ -f "$folder"/tmp/errors-list.jsonl ]; then
  rm "$folder"/tmp/errors-list.jsonl
fi

# per ogni log json di frictionless, estrai nome file e righe errori
find "$folder"/tmp/ -maxdepth 1 -iname "prov*.json" -type f -print0 | while IFS= read -r -d '' line; do
  check=$(jq -r '.valid' "$line")
  name=$(basename "$line" .json)
  if [ "$check" == "false" ]; then
    echo "$line"
    jq <"$line" -c '.tasks[0].errors[]|{file:"'"$name"'",rowNumber:.rowNumber,rowPosition:.rowPosition}' >>"$folder"/tmp/errors-list.jsonl
  fi
done

# se sono stati trovati errori, crea report
if [ -f "$folder"/tmp/errors-list.jsonl ]; then
  echo "ERRORE: sono stati trovati errori nei CSV provinciali"
  # nella lista errori, estrai righe univoche
  mlr -I --json uniq -a "$folder"/tmp/errors-list.jsonl

  cp "$folder"/tmp/errors-list.jsonl "$folder"/../../dati/"$nome"/report/province-errors-list.jsonl

  URL="https://github.com/ondata/sesso-e-potere/blob/main/dati/amministazioni-italiane/rawdata/"

  # crea file markdown lista errori
  mlr --j2m put '$file="[".$file."]('$URL'".$file.".csv#L".$rowPosition.")"' "$folder"/tmp/errors-list.jsonl >"$folder"/../../dati/"$nome"/report/province-errors-list.md
# se non ne hai trovati, cancella i file di report
else
  find "$folder"/../../dati/"$nome"/report/ -maxdepth 1 -iname "*errors-list*" -type f -delete
fi
