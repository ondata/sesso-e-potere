#!/bin/bash

set -x
set -e
set -u
set -o pipefail

nome="amministazioni-italiane"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../dati/"$nome"/rawdata
mkdir -p "$folder"/../../dati/"$nome"/processing

URL="https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica"

# scarica lista file
curl "$URL" \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' \
  --compressed | scrape -be '//span[@class="file"]/a' | xq -c '.html.body.a[]' >"$folder"/../../dati/"$nome"/rawdata/"$nome".jsonl

cd "$folder"/../../dati/"$nome"/rawdata/

# scarica file
scaricadati="no"
if [ $scaricadati = "sì" ]; then
  jq <"$folder"/../../dati/amministazioni-italiane/rawdata/amministazioni-italiane.jsonl -r '."@href"' | grep -v 'provincia_di_agrigento.zip' | while read line; do
    wget -c --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.1.17 (KHTML, like Gecko) Version/8.0 Safari/600.1.17" "$line"
  done
fi

if [ -f "$folder"/../../dati/"$nome"/processing/tmp.jsonl ]; then
  rm "$folder"/../../dati/"$nome"/processing/tmp.jsonl
fi

find "$folder"/../../dati/amministazioni-italiane/rawdata/ -type f -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  nomefile=$(basename "$line" .csv)
  tail <"$line" -n +3 | mlrgo --icsv --ojsonl --ragged --ifs ";" put '$filename="'"$nomefile"'"' >>"$folder"/../../dati/"$nome"/processing/tmp.jsonl
done

mlrgo --ijsonl --ocsv unsparsify "$folder"/../../dati/"$nome"/processing/tmp.jsonl >"$folder"/../../dati/"$nome"/processing/file-provinciali.csv

rm "$folder"/../../dati/"$nome"/processing/tmp.jsonl

rm "$folder"/../../dati/"$nome"/rawdata/"$nome".jsonl

find  "$folder"/../../dati/amministazioni-italiane/rawdata/ -type f ! -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  nomefile=$(basename "$line" .csv)
  frictionless extract --field-type TEXT --csv --buffer-size 250000 "$line" >"$folder"/../../dati/"$nome"/processing/"$nomefile".csv
done
