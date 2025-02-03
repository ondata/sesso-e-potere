#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../dati/ambasciate
mkdir -p "$folder"/../../dati/ambasciate/processing
mkdir -p "$folder"/tmp

mlr --csv --from "$folder"/../../dati/ambasciate/rawdata/ambasciate.csv clean-whitespace then sort -f paese -tr web-scraper-order >"$folder"/../../dati/ambasciate/processing/ambasciate.csv

mlr -I -S --csv --from "$folder"/../../dati/ambasciate/processing/ambasciate.csv put '$AMBASCIATORE=sub($AMBASCIATORE,"AMBASCIATORE:","");$AMBASCIATA=sub($AMBASCIATA,"AMBASCIATA -","")' then clean-whitespace

# cancella con find -delete tutto il contenuto in "$folder"/tmp
find "$folder"/tmp -type f -maxdepth 1 -delete

mlr --c2n --from "$folder"/../../dati/ambasciate/processing/ambasciate.csv filter 'is_not_null($AMBASCIATORE)' then cut -f AMBASCIATORE then uniq -a >"$folder"/tmp/ambasciatori.txt

cat "$folder"/tmp/ambasciatori.txt | while read -r line; do
  echo "$line"
  llm --no-stream "$line" -t sesso -o json_object true >>"$folder"/tmp/nomi.jsonl
  sleep 5
done
