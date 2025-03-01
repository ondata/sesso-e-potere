#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

find "${folder}"/../rawdata -type f -name "*.csv" -delete

find "${folder}"/../input -type f -name "*.xlsx" | while read -r file; do
  nome=$(basename "${file}" .xlsx)
  qsv excel --metadata j "${file}" >"${folder}"/tmp/"${nome}".jsonl
  cat "${folder}"/tmp/"${nome}".jsonl | jq -c '.sheet[]' | while read -r line; do
    echo "$line"

    name=$(echo "$line" | jq -r '.name')

    # crea versione snake case del nome
    name_snake=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

    qsv excel -Q --sheet "${name}" "${file}" > "${folder}"/../rawdata/"${name_snake}".csv

    # pulizia varia
    mlr -I -S --csv clean-whitespace then remove-empty-columns then rename sesso,S,start-url,link "${folder}"/../rawdata/"${name_snake}".csv

    # normalizza i nomi delle colonne
    duckdb --csv -c "select * from read_csv_auto('${folder}/../rawdata/${name_snake}.csv',normalize_names=true)" >"${folder}"/tmp/tmp.csv
    mv "${folder}"/tmp/tmp.csv "${folder}"/../rawdata/"${name_snake}".csv
  done
done
