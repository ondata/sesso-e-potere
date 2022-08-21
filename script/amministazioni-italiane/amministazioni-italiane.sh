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

URL="https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica"

# cancella eventuali file temporanei
find "$folder"/../../dati/amministazioni-italiane/processing -type f -iname "tmp*" -delete

# scarica lista file
curl "$URL" \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' \
  --compressed | scrape -be '//span[@class="file"]/a' | xq -c '.html.body.a[]' >"$folder"/../../dati/"$nome"/rawdata/"$nome".jsonl

cd "$folder"/../../dati/"$nome"/rawdata/

# scarica file. Se impostato a "sì", scarica di nuovi i dati grezzi dalla sorgente
scaricadati="no"
if [ $scaricadati = "sì" ]; then
  jq <"$folder"/../../dati/amministazioni-italiane/rawdata/amministazioni-italiane.jsonl -r '."@href"' | grep -v 'provincia_di_agrigento.zip' | while read line; do
    wget -c --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.1.17 (KHTML, like Gecko) Version/8.0 Safari/600.1.17" "$line"
  done
fi

# elimina file temporaneo usato per fare dopo il merge dei dati raggruppati per provincia
if [ -f "$folder"/../../dati/"$nome"/processing/tmp.jsonl ]; then
  rm "$folder"/../../dati/"$nome"/processing/tmp.jsonl
fi

# raggruppa in unico file JSON Lines i dati grezzi comunali raggruppati per provincia
find "$folder"/../../dati/amministazioni-italiane/rawdata/ -type f -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  nomefile=$(basename "$line" .csv)
  tail <"$line" -n +3 | mlrgo --icsv --ojsonl --ragged --ifs ";" put '$filename="'"$nomefile"'"' >>"$folder"/../../dati/"$nome"/processing/tmp.jsonl
done

# coverti il file JSON Lines in un file CSV
mlrgo --ijsonl --ocsv unsparsify "$folder"/../../dati/"$nome"/processing/tmp.jsonl >"$folder"/../../dati/"$nome"/processing/file-provinciali.csv

# cancella file non più utili
rm "$folder"/../../dati/"$nome"/processing/tmp.jsonl
rm "$folder"/../../dati/"$nome"/rawdata/"$nome".jsonl

# normalizza file CSV non provinciali (encoding UTF-8, separatore ",", rimuovi intestazioni ridondanti)
find "$folder"/../../dati/amministazioni-italiane/rawdata/ -type f ! -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  nomefile=$(basename "$line" .csv)
  frictionless extract --field-type TEXT --csv --buffer-size 250000 "$line" >"$folder"/../../dati/"$nome"/processing/"$nomefile".csv
done

# aggiungi i codici elettorali comuni ai dati di tipo comunale e poi fai JOIN per aggiungere codici comunali ISTAT
grep -lr --include=\*.csv "$folder"/../../dati/amministazioni-italiane/processing -e 'codice_comune' | while read line; do
  echo "$line"
  mlr -I --csv put -S '$comune=$codice_regione.$codice_provincia.$codice_comune' "$line"
  mlr --csv join --ul -j comune -f "$line" then unsparsify "$folder"/../../dati/"$nome"/risorse/comuni.csv >"$folder"/tmp.csv
  mv "$folder"/tmp.csv "$line"
done


# estrai elenco comuni non presenti in Amministratori locali e regionali in carica"
mlr --csv cut -f comune then uniq -a "$folder"/../../dati/"$nome"/processing/ammcom.csv >"$folder"/tmp.csv

mlr --csv join --ul --np -j comune -f "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv then unsparsify then uniq -a "$folder"/tmp.csv >"$folder"/../../dati/"$nome"/report/ammcom-non-presenti.csv

if [ -f >"$folder"/tmp.csv ]; then
  rm "$folder"/tmp.csv
fi
