#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../dati/ministero-interno-posizioni-organizzative
mkdir -p "$folder"/../../dati/ministero-interno-posizioni-organizzative/rawdata
mkdir -p "$folder"/../../dati/ministero-interno-posizioni-organizzative/processing
mkdir -p "$folder"/tmp

curl -kL "https://www.interno.gov.it/it/amministrazione-trasparente/personale/posizioni-organizzative" | scrape -be '.file--application-pdf a' | xq -c '.html.body.a[]' >"$folder"/tmp/lista.jsonl

#https://www.interno.gov.it/sites/default/files/2025-02/uff_i_posizorganizz_2025.pdf

while read -r line; do
  path=$(echo "$line" | jq -r '."@href"')
  nome=$(echo "$line" | jq -r '."#text"')
  file=$(basename "$path")

  # se il file esiste non lo scarico
  if [ ! -f "$folder"/../../dati/ministero-interno-posizioni-organizzative/rawdata/"$file" ]; then
    curl -kL "https://www.interno.gov.it/${path}" >"$folder"/../../dati/ministero-interno-posizioni-organizzative/rawdata/"$file"
  fi
done <"$folder"/tmp/lista.jsonl

for pdf in "$folder"/../../dati/ministero-interno-posizioni-organizzative/rawdata/*.pdf; do
  nome=$(basename "$pdf" .pdf)
  llm -t ministero-interno-posizioni-organizzative -a "$pdf" > "$folder"/../../dati/ministero-interno-posizioni-organizzative/processing/"$nome".jsonl
  # aggiungi al file jsonl la proprietò filename: "$nome"
  sleep 2
done
