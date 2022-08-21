- [Note per il Dipartimento per gli Affari Interni e Territoriali](#note-per-il-dipartimento-per-gli-affari-interni-e-territoriali)
  - [Non sono presenti i dati su tutti i comuni di Italia](#non-sono-presenti-i-dati-su-tutti-i-comuni-di-italia)
  - [Titolo pagina](#titolo-pagina)
  - [Dichiarare l'encoding](#dichiarare-lencoding)
  - [I file CSV non hanno una sintassi corretta](#i-file-csv-non-hanno-una-sintassi-corretta)
  - [Formato campi da cambiare in ISO 8601](#formato-campi-da-cambiare-in-iso-8601)

# Note per il Dipartimento per gli Affari Interni e Territoriali

## Non sono presenti i dati su tutti i comuni di Italia

Ci sono 7.565 su 7.904.

## Titolo pagina

Al momento è "Amministratori locali e regionali in carica".


Cambiarlo in "Amministratori e Amministratici locali e regionali in carica".

## Dichiarare l'encoding

Sul sito non è documentato, e può creare qualche problema di utilizzo. Sembra `iso8859-1`.

## I file CSV non hanno una sintassi corretta

Nel documento che fa da riferimento per il formato `CSV` si legge:

> Fields containing line breaks (CRLF), double quotes, and commas should be enclosed in double-quotes.

Quindi se una cella contiene delle `"`, la cella deve essere inserita tra `"` deve essere fatto l'escape di `"` presenti internamente alle celle.

In questi CSV la cosa non è rispettata e si ha

```
LISTA CIVICA | "SAINT-OYEN - TRAVAILLI EUNSEMBLO"
```

mentre dovrebbe essere

```
"LISTA CIVICA | ""SAINT-OYEN - TRAVAILLI EUNSEMBLO"""
```

## Formato campi da cambiare in ISO 8601

Al momento sono `gg/mm/aaaa` (ad esempio "25/03/2019"). I campi date sono di grande interesse e ottimizzarli in formato `AAAA-MM-DD` (ad esempio "2019-03-25") è molto preferibile.
