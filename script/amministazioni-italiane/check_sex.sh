#!/bin/bash

set -x
set -e
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

while IFS= read -r line; do

    nome=$(basename "${line}" .csv)

    mlr --c2n --from "${line}" cut -f nome,sesso then filter 'is_null($sesso)' then uniq -a then cut -f nome > "${folder}/tmp/nomi_${nome}.txt"

    # Esecuzione sesso.sh con isolamento dello stdin
    if ! sesso.sh -f "${folder}/tmp/nomi_${nome}.txt" > "${folder}/tmp/sesso_${nome}.jsonl" 2>/dev/null < /dev/null; then
        echo "ERRORE: sesso.sh è uscito con errore per '${nome}'"
        continue
    fi

    mlr --ijsonl --ocsv cat "${folder}/tmp/sesso_${nome}.jsonl" > "${folder}/tmp/sesso_${nome}.csv"

    mlr -I -S --csv put '$nome=toupper($nome)' "${folder}/tmp/sesso_${nome}.csv"

    mlr --csv filter 'is_null($sesso)' "${line}" > "${folder}/tmp/${nome}_sesso_NA.csv"
    mlr --csv filter -x 'is_null($sesso)' "${line}" > "${folder}/tmp/${nome}_sesso.csv"

    mlr --csv join --ul -j nome -f "${folder}/tmp/${nome}_sesso_NA.csv" then unsparsify  "${folder}/tmp/sesso_${nome}.csv" > "${folder}"/tmp/tmp.csv

    mv "${folder}/tmp/tmp.csv" "${folder}/tmp/${nome}_sesso_NA.csv"

    mlr --csv unsparsify "${folder}/tmp/${nome}_sesso.csv" "${folder}/tmp/${nome}_sesso_NA.csv" > "${folder}/tmp/${nome}.csv"

    mlr -I -S --csv sort -t codice_regione,codice_provincia,codice_comune "${folder}/tmp/${nome}.csv"

    cp "${folder}/tmp/${nome}.csv" "${folder}"/../../dati/amministazioni-italiane/processing

    sleep 3

done < "${folder}/tmp/dacontrollare.txt"

for file in "${folder}"/../../dati/amministazioni-italiane/processing/*.csv; do
  mlr -I -S --csv sort -t codice_regione,codice_provincia,codice_comune "${file}"
done
