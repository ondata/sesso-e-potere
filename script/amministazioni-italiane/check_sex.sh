#!/bin/bash

set -x
#set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

# svuota la cartella senza eliminarla
find "${folder}"/tmp -mindepth 1 -delete

# trova tutti i file CSV che non sono valorizzati con sesso
grep -L 'sesso' "${folder}"/../../dati/amministazioni-italiane/processing/*.csv >"${folder}"/tmp/dacontrollare.txt

while read -r line; do
  nome=$(basename "${line}" .csv)
  mlr --c2n cut -f nome then uniq -a "${line}" >"${folder}"/tmp/nomi_"${nome}".txt
  sesso.sh -f "${folder}"/tmp/nomi_"${nome}".txt >"${folder}"/tmp/sesso_"${nome}".jsonl
  mlr --ijsonl --ocsv cat "${folder}"/tmp/sesso_"${nome}".jsonl >"${folder}"/tmp/sesso_"${nome}".csv
  mlr --csv join -j nome -f "${line}" then unsparsify "${folder}"/tmp/sesso_"${nome}".csv >"${folder}"/tmp/"${nome}"_sesso.csv

  cp "${folder}"/tmp/"${nome}"_sesso.csv "${line}"
done <"${folder}"/tmp/dacontrollare.txt

# svuota la cartella senza eliminarla
find "${folder}"/tmp -mindepth 1 -delete

# per ogni file in "${folder}"/../../dati/amministazioni-italiane/processing/*.csv conta quante righe
for file in "${folder}"/../../dati/amministazioni-italiane/processing/*.csv; do
  nome=$(basename "${file}" .csv)
  conteggio=$(mlr --c2n cut -f sesso then filter 'is_null($sesso)' "${file}" | wc -l)
  if [ "${conteggio}" -gt 0 ]; then
    echo "${file}" >>"${folder}"/tmp/dacontrollare.txt
  fi
done

cat "${folder}"/tmp/dacontrollare.txt
sleep 3

while read -r line; do
  nome=$(basename "${line}" .csv)
  mlr --c2n cut -f nome,sesso then filter 'is_null($sesso)' then uniq -a then cut -f nome "${line}" >"${folder}"/tmp/nomi_"${nome}".txt
  #sesso.sh -f "${folder}"/tmp/nomi_"${nome}".txt >"${folder}"/tmp/sesso_"${nome}".jsonl
  # echo exit code: $?
  echo "Codice di uscita: $?"
  echo "File: ${line}"

  sleep 3
done <"${folder}"/tmp/dacontrollare.txt
