# Intro

Si tratta dei dati su amministratori e amministratici locali e regionali in carica.

La fonte di questi dati è il Dipartimento per gli Affari Interni e Territoriali:<br>
<https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica>

# Dati grezzi

I dati grezzi, senza modifiche, sono nella cartella [`raw`](rawdata).

Info generali:

- formato: `CSV`
- separatore di campo: `;`
- *encoding*: `ISO8859-1` (non è un'informazione presente a monte, è derivata in modo automatico)
- righe di intestazione superflue: le prime due

# Dati elaborati

I file grezzi presenti in [`raw`](rawdata) sono stati elaborati e resi disponibili nella cartella [`processing`](processing).

Queste le modifiche fatte:

- cambiato separatore di campo da `;` a `,`;
- cambiato *encoding* da `ISO8859-1` a `UTF-8`;
- corretta sintassi di celle con `"` all'interno (vedi [note](note.md#i-file-csv-non-hanno-una-sintassi-corretta));
- rimosse righe di intestazioni superflue;
- per il file `ammcom.csv`, con i dati comunali, aggiunte le colonne `data_elezione_ISO` e `data_entrata_in_carica_ISO` in formato `YYYY-MM-DD`;

# Note

Qui un file con delle [note](note.md) sui dati.
