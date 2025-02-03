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

mlr -I -S --csv --from "$folder"/../../dati/ambasciate/processing/ambasciate.csv put '$AMBASCIATORE=sub($AMBASCIATORE,".+:","");$AMBASCIATA=sub($AMBASCIATA,"AMBASCIATA -","")' then clean-whitespace

# cancella con find -delete tutto il contenuto in "$folder"/tmp
#find "$folder"/tmp -type f -maxdepth 1 -delete

mlr --c2n --from "$folder"/../../dati/ambasciate/processing/ambasciate.csv filter 'is_not_null($AMBASCIATORE)' then cut -f AMBASCIATORE then uniq -a >"$folder"/tmp/ambasciatori.txt

#sesso.sh -f "$folder"/tmp/ambasciatori.txt >"$folder"/tmp/ambasciatori.jsonl

mlr --csv --implicit-csv-header label AMBASCIATORE then cat -n "$folder"/tmp/ambasciatori.txt >"$folder"/tmp/ambasciatori.csv

mlr --ijsonl --ocsv cat -n "$folder"/tmp/ambasciatori.jsonl >"$folder"/tmp/ambasciatori_nomi.csv

mlr --csv join --ul -j n -f "$folder"/tmp/ambasciatori.csv then unsparsify then cut -x -f n "$folder"/tmp/ambasciatori_nomi.csv >"$folder"/../../dati/ambasciate/processing/nomi.csv

mlr --csv join --ul -j AMBASCIATORE -f "$folder"/../../dati/ambasciate/processing/ambasciate.csv then unsparsify then sort -f paese -tr web-scraper-order "$folder"/../../dati/ambasciate/processing/nomi.csv >"$folder"/../../dati/ambasciate/processing/tmp.csv

mv "$folder"/../../dati/ambasciate/processing/tmp.csv "$folder"/../../dati/ambasciate/processing/ambasciate.csv

mlr --csv cut -f paese then filter -x 'is_null($paese) || $paese=~".*:.*"' then uniq -a "$folder"/../../dati/ambasciate/processing/ambasciate.csv | llm -s 'sei un sistema che prende un elenco di nomi di paesi, e restituisce in output elenco arricchito dalla colonna con il codice ISO 3166-1 alpha-3. Quando non applicabile lo lasci vuoto. Ed esporti in JSON, {"paese":"Italia","codice":"ITA"}' -o json_object true >"$folder"/tmp/paesi.jsonl

mlr --ijson --ocsv cat "$folder"/tmp/paesi.jsonl >"$folder"/tmp/paesi.csv

mlr --csv join --ul -j paese -f "$folder"/../../dati/ambasciate/processing/ambasciate.csv then unsparsify then sort -f paese -tr web-scraper-order "$folder"/tmp/paesi.csv >"$folder"/../../dati/ambasciate/processing/tmp.csv

mv "$folder"/../../dati/ambasciate/processing/tmp.csv "$folder"/../../dati/ambasciate/processing/ambasciate.csv

mlr --csv filter 'is_not_null($codice) && is_not_null($sesso)' "$folder"/../../dati/ambasciate/processing/ambasciate.csv >"$folder"/tmp/mappa.csv

mlr -I --csv rename -r '"web-scraper-",' then cut -x -f order "$folder"/../../dati/ambasciate/processing/ambasciate.csv
