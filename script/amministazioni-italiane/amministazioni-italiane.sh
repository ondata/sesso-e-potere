#!/bin/bash

set -x
set -e
set -u
set -o pipefail

nome="amministazioni-italiane"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crea le directory necessarie per i dati grezzi, elaborati e report
mkdir -p "${folder}"/../../dati/"$nome"/rawdata
mkdir -p "${folder}"/../../dati/"$nome"/processing
mkdir -p "${folder}"/../../dati/"$nome"/report
mkdir -p "${folder}"/tmp

URL="https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica"

# cancella eventuali file temporanei
find "${folder}"/../../dati/amministazioni-italiane/processing -type f -iname "tmp*" -delete

# scarica lista file
curl "$URL" \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' \
  --compressed | scrape -be '//span[@class="file"]/a' | xq -c '.html.body.a[]' >"${folder}"/../../dati/"$nome"/rawdata/"$nome".jsonl

# sposta nella directory dei dati grezzi
cd "${folder}"/../../dati/"$nome"/rawdata/

# scarica file. Se impostato a "sì", scarica di nuovo i dati grezzi dalla sorgente
scaricadati="no"
if [ $scaricadati = "sì" ]; then
  find "${folder}"/../../dati/amministazioni-italiane/rawdata/ -maxdepth 1 -iname "*.csv" -type f -delete
  jq <"${folder}"/../../dati/amministazioni-italiane/rawdata/"${nome}".jsonl -r '."@href"' | while read line; do
    wget -c --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.1.17 (KHTML, like Gecko) Version/8.0 Safari/600.1.17" "$line"
  done
fi

# torna alla directory dello script
cd "${folder}"

# elimina file temporaneo usato per fare dopo il merge dei dati raggruppati per provincia
if [ -f "${folder}"/../../dati/"$nome"/processing/tmp.jsonl ]; then
  rm "${folder}"/../../dati/"$nome"/processing/tmp.jsonl
fi


# raggruppa in unico file JSON Lines i dati grezzi comunali raggruppati per provincia
find "${folder}"/../../dati/amministazioni-italiane/rawdata/ -type f -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  nomefile=$(basename "$line" .csv)

  encoding=$(chardetect --minimal "$line")

  # Normalize encoding names
  if [[ "${encoding,,}" == "macroman" ]]; then
    encoding="macintosh"
  fi

  if [[ "${encoding,,}" == "utf-8" || "${encoding,,}" == "ascii" ]]; then
    cat "${folder}"/../../dati/amministazioni-italiane/rawdata/"$nomefile".csv | tail -n +3 | mlrgo --icsv --ojsonl --fs ";" --jvquoteall -S --ragged cat >> "${folder}"/../../dati/"$nome"/processing/tmp.jsonl
  else
    cat "${folder}"/../../dati/amministazioni-italiane/rawdata/"$nomefile".csv | iconv -f "$encoding" -t utf-8 | tail -n +3 | mlrgo --icsv --ojsonl --fs ";" --jvquoteall -S --ragged cat >> "${folder}"/../../dati/"$nome"/processing/tmp.jsonl
  fi
done

# coverti il file JSON Lines in un file CSV
mlrgo --ijsonl --ocsv --no-auto-flatten unsparsify  "${folder}"/../../dati/"$nome"/processing/tmp.jsonl >"${folder}"/../../dati/"$nome"/processing/file-provinciali.csv

# cancella file non più utili
rm "${folder}"/../../dati/"$nome"/processing/tmp.jsonl
rm "${folder}"/../../dati/"$nome"/rawdata/"$nome".jsonl

# rimuovi il file temporaneo della lista se esiste
if [ -f "${folder}"/../../dati/"$nome"/risorse/lista-file.jsonl ];then
  rm "${folder}"/../../dati/"$nome"/risorse/lista-file.jsonl
fi

# normalizza file CSV non provinciali (encoding UTF-8, separatore ",", rimuovi intestazioni ridondanti)
find "${folder}"/../../dati/amministazioni-italiane/rawdata/ -type f ! -iname "prov*.csv" -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  titolo=$(cat "$line" | sed -n '1p' | tr -d '\r')
  note=$(cat "$line" | sed -n '2p' | tr -d '\r')
  nomefile=$(basename "$line" .csv)
  encoding=$(chardetect --minimal "$line")

  # Normalize encoding names
  if [[ "${encoding,,}" == "macroman" ]]; then
    encoding="macintosh"
  fi

  if [[ "${encoding,,}" == "utf-8" || "${encoding,,}" == "ascii" ]]; then
    cat "$line" | tail -n +3 | mlrgo --csv --ifs ";" -S --ragged remove-empty-columns >"${folder}"/../../dati/"$nome"/processing/"$nomefile".csv
  else
    iconv -f "$encoding" -t utf-8 "$line" | tail -n +3 | mlrgo --csv --ifs ";" -S --ragged remove-empty-columns >"${folder}"/../../dati/"$nome"/processing/"$nomefile".csv
  fi

  # Remove any existing double quotes from the values and add single quotes for JSON
  titolo_clean=$(echo "$titolo" | tr -d '"')
  note_clean=$(echo "$note" | tr -d '"')
  echo '{"nomefile":"'"$nomefile"'","titolo":"'"$titolo_clean"'","note":"'"$note_clean"'"}' >>"${folder}"/../../dati/"$nome"/risorse/lista-file.jsonl

  sleep 0
done

# converti la lista file da JSON Lines a CSV e pulisci gli spazi
mlr --j2c clean-whitespace "${folder}"/../../dati/"$nome"/risorse/lista-file.jsonl >"${folder}"/../../dati/"$nome"/risorse/lista-file.csv

# aggiungi i codici elettorali comuni ai dati di tipo comunale e poi fai JOIN per aggiungere codici comunali ISTAT
grep -lr --include=\*.csv "${folder}"/../../dati/amministazioni-italiane/processing -e 'codice_comune' | while read line; do
  echo "$line"
  mlr -I --csv remove-empty-columns then put -S '$comune=$codice_regione.$codice_provincia.$codice_comune' "$line"
  mlr --csv join --ul -j comune -f "$line" then unsparsify "${folder}"/../../dati/"$nome"/risorse/comuni.csv >"${folder}"/tmp.csv
  mv "${folder}"/tmp.csv "$line"
done



# estrai elenco comuni non presenti in Amministratori locali e regionali in carica"
mlr --csv cut -f comune then uniq -a "${folder}"/../../dati/"$nome"/processing/ammcom.csv >"${folder}"/tmp.csv

mlr --csv join --ul --np -j comune -f "${folder}"/../../dati/"$nome"/risorse/codici_comuni.csv then unsparsify then uniq -a "${folder}"/tmp.csv >"${folder}"/../../dati/"$nome"/report/ammcom-non-presenti.csv

# rimuovi il file temporaneo se esiste
if [ -f >"${folder}"/tmp.csv ]; then
  rm "${folder}"/tmp.csv
fi


# estrai comuni, che per la stessa carica hanno due date di elezione diverse
mlr --csv uniq -f comune,data_elezione,descrizione_carica then count-similar -o conteggio -g comune,descrizione_carica then filter '$conteggio>1' then sort -f  comune,descrizione_carica,data_elezione then cut -x -f conteggio then reorder -f comune,descrizione_carica,data_elezione "${folder}"/../../dati/"$nome"/processing/ammcom.csv >"${folder}"/../../dati/"$nome"/report/comuni-cariche-duplicate-data.csv

# aggiungere colonne date in formato ISO 8601 per data_elezione, e data_entrata_in_carica
grep -lr --include=\*.csv "${folder}"/../../dati/amministazioni-italiane/processing -e 'data_elezione,data_entrata_in_carica' | while read line; do
  echo "$line"
  name=$(basename "$line" .csv)
  mlr --csv filter -S -x '$data_elezione=~"[0-9]+/[0-9]+"' "$line" >"${folder}"/tmp/tmp-"$name"-errors.csv
  mlr -I --csv filter -S '$data_elezione=~"[0-9]+/[0-9]+"' then put '$data_elezione_ISO=strftime(strptime($data_elezione, "%d/%m/%Y"),"%Y-%m-%d");$data_entrata_in_carica_ISO=strftime(strptime($data_entrata_in_carica, "%d/%m/%Y"),"%Y-%m-%d")' "$line"
done

# clean-whitespace
grep -lr --include=\*.csv "${folder}"/../../dati/amministazioni-italiane/processing -e 'data_elezione_ISO,data_entrata_in_carica_ISO' | while read line; do
  echo "$line"
  mlr -I -S --csv clean-whitespace "$line"
done
