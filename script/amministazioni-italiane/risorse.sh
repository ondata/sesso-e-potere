#!/bin/bash

set -x
set -e
set -u
set -o pipefail

nome="amministazioni-italiane"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../dati/"$nome"/rawdata
mkdir -p "$folder"/../../dati/"$nome"/processing
mkdir -p "$folder"/../../dati/"$nome"/risorse


# scarica codici elettorali comuni
curl 'https://dait.interno.gov.it/territorio-e-autonomie-locali/sut/elenco_codici_comuni_csv.php' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36' \
  --compressed > "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv


# rimuovi le " e =
sed -i -r 's/(\"|=)//g' "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv
# cambia separatore di campo da ";" a ","
mlr -I --csv --ifs ";" clean-whitespace "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv

# aggiungi codice comune così come da API eligengo
mlr -I --csv put -S '$comune=sub(${CODICE ELETTORALE},"^.","")' "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv

mlr --csv cut -f "CODICE ISTAT",comune then label CODICE_ISTAT,comune "$folder"/../../dati/"$nome"/risorse/codici_comuni.csv >"$folder"/../../dati/"$nome"/risorse/comuni.csv
