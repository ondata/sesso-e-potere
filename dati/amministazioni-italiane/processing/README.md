# Introduzione

La fonte dei dati è la sezione del sito del Dipartimento per gli Affari Interni e Territoriali del Ministero dell'Interno, denominata Amministratori locali e regionali in carica:
<https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica>

## I dati disponibili

Sul sito di origine diverse fonti dati, su più file. Sono stati scaricati, ripuliti e arricchiti e dispoinibili in formato CSV:

| nomefile                  | titolo                                                 | note                         |
|---------------------------|--------------------------------------------------------|------------------------------|
| [`organistraordinariincarica.csv`](./organistraordinariincarica.csv) | Organi straordinari di governo - elenco completo Italia | Aggiornato al 17/01/2025     |
| [`maggiororgano.csv`](./maggiororgano.csv)             | Maggior organo in carica nei Comuni - elenco completo Italia | Aggiornato al 17/01/2025     |
| [`ammprov.csv`](ammprov.csv)                   | Amministratori Provinciali - elenco completo Italia    | Aggiornato al 17/01/2025     |
| [`ammreg.csv`](ammreg.csv)                    | Amministratori Regionali - elenco completo Italia      | Aggiornato al 17/01/2025     |
| [`sindaciincarica.csv`](./sindaciincarica.csv)           | Sindaci - elenco completo Italia                      | Aggiornato al 17/01/2025     |
| [`ammcom.csv`](./ammcom.csv)                    | Amministratori Comunali - elenco completo Italia      | Aggiornato al 17/01/2025     |
| [`ammmetropolitani.csv`](./ammmetropolitani.csv)          | Amministratori Metropolitani - elenco completo Italia | Aggiornato al 17/01/2025     |

A questi è stato aggiunto il file [`file-provinciali.csv`](./file-provinciali.csv) che contiene l'unione di tutti i file presenti nel sito originale suddivisi per provincia (Amministratori comunali della Provincia Agrigento, Amministratori comunali della Provincia Alessandria, ecc.).

## LOG

### 2025-02-02

- Aggiornati i file con i dati al 17/01/2025, ovvero i più aggiornati a questa data;
- Di alcuni Comuni non sono presenti dati (quelli del file [`ammcom-non-presenti.csv`](../amministazioni-italiane/report/ammcom-non-presenti.csv))
- Aggiunta la colonna "sesso" al file [`organistraordinariincarica.csv`](./organistraordinariincarica.csv), che in origine non era presente;
- valorizzata la colonna "sesso" nelle decine di righe in cui non era valorizzato nei [file originali](../rawdata/) (valorizzati adesso in [`ammcom.csv`](./ammcom.csv), [`ammprov.csv`](./ammprov.csv), [`file-provinciali.csv`](./file-provinciali.csv), [`maggiororgano.csv`](./maggiororgano.csv));
- sono stati aggiunti i codici comunali Istat, nella colonna `CODICE_ISTAT`, per tutti i dati con taglio comunale;
- normalizzato l'enconding dei caratteri, che in origine non sono tutti in `utf-8`.
