#!/bin/bash

# Requisiti:
# - qsv: per manipolare file Excel e CSV (https://github.com/jqnatividad/qsv)
# - jq: per elaborare JSON (https://stedolan.github.io/jq/)
# - mlr (Miller): per manipolare dati tabulari (https://github.com/johnkerl/miller)
# - duckdb: per operazioni SQL su file CSV (https://duckdb.org/)

# Impostazioni per rendere lo script più robusto
set -x                  # Mostra i comandi mentre vengono eseguiti
set -e                  # Termina lo script se un comando fallisce
set -u                  # Termina lo script se viene usata una variabile non definita
set -o pipefail         # Fa fallire una pipeline se uno dei comandi fallisce

# Ottieni il percorso della directory dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea la directory temporanea se non esiste
mkdir -p "${folder}"/tmp

# Elimina tutti i file CSV esistenti nella directory rawdata
find "${folder}"/../rawdata -type f -name "*.csv" -delete

# Elabora ogni file Excel nella directory input
find "${folder}"/../input -type f -name "*.xlsx" | while read -r file; do
  # Estrai il nome del file senza estensione
  nome=$(basename "${file}" .xlsx)

  # Estrai i metadati del file Excel in formato JSON
  qsv excel --metadata j "${file}" >"${folder}"/tmp/"${nome}".jsonl

  # Elabora ogni foglio del file Excel
  cat "${folder}"/tmp/"${nome}".jsonl | jq -c '.sheet[]' | while read -r line; do
    echo "$line"

    # Estrai il nome del foglio
    name=$(echo "$line" | jq -r '.name')

    # Crea versione snake case del nome
    name_snake=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

    # Converti il foglio Excel in CSV
    qsv excel -Q --sheet "${name}" "${file}" > "${folder}"/../rawdata/"${name_snake}".csv

    # Pulizia varia: rimuovi spazi bianchi, colonne vuote e rinomina alcune colonne
    mlr -I -S --csv clean-whitespace then remove-empty-columns then rename sesso,S,start-url,link "${folder}"/../rawdata/"${name_snake}".csv

    # Normalizza i nomi delle colonne usando DuckDB
    duckdb --csv -c "select * from read_csv_auto('${folder}/../rawdata/${name_snake}.csv',normalize_names=true)" >"${folder}"/tmp/tmp.csv
    mlr -S --csv cat "${folder}"/tmp/tmp.csv >"${folder}"/../rawdata/"${name_snake}".csv
  done
done
