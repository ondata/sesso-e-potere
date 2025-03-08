# Introduzione

In questa pagina trovi l'elenco dei **principali dati** che abbiamo usato per l'**edizione 2025** di [**SESSO È POTERE**](https://infonodes.org/sesso-%C3%A8-potere).  È un'inchiesta realizzata da [**info.nodes**](https://www.infonodes.org/) in collaborazione con **onData**, che analizza le disuguaglianze di genere nella rappresentanza e nella gestione del potere in Italia.

I dati sono divisi in categorie e corredati (ove applicabile/possibile) a queste informazioni:

- `Titolo`, ovvero il titolo della fonte da cui sono stati estratti i dati;
- `URL`, ovvero il link alla fonte da cui sono stati estratti i dati;
- `Sheet`, ovvero il link al foglio di lavoro Google in cui è presente una copia dei dati;
- `RAW_DATA`, ovvero un file CSV reso disponibile per elaborazioni "grezze" dei dati. Sono file CSV con separatore di campo `,` e codifica `UTF-8`, che abbiamo pulito e normalizzato. Abbiamo creato anche una [versione *machine to machine*](https://github.com/ondata/sesso-e-potere/blob/main/dati/2025/index.yaml) dell'indice di questi `CSV`.

I dati sono stati estratti tra gennaio e febbraio 2025.

## Indice dei dati

<!-- no toc -->
- [POLITICA](#politica)
  - [Governo - Presidente](#governo---presidente)
  - [Governo](#governo)
  - [Camera - Presidente](#camera---presidente)
  - [Camera](#camera)
  - [Senato - Presidente](#senato---presidente)
  - [Senato](#senato)
  - [Ambasciate](#ambasciate)
  - [Sindaci](#sindaci)
  - [Consiglio e Giunta dei Comuni](#consiglio-e-giunta-dei-comuni)
  - [Presidenza Regione, Giunta Regione e Consiglio Regione](#presidenza-regione-giunta-regione-e-consiglio-regione)
- [ECONOMIA](#economia)
  - [MEF](#mef)
  - [Società quotate - CEO e Presidente](#società-quotate---ceo-e-presidente)
  - [Gruppi bancari](#gruppi-bancari)
  - [Gruppi Tech](#gruppi-tech)
- [MEDIA](#media)
  - [Quotidiani](#quotidiani)
  - [TG](#tg)
  - [Agenzie di stampa](#agenzie-di-stampa)
- [SOCIETÀ](#società)
  - [Atenei](#atenei)
  - [Enti di ricerca](#enti-di-ricerca)
  - [Autorità indipendenti](#autorità-indipendenti)
- [CONTESTO](#contesto)
  - [Percentuale residenti](#percentuale-residenti)
  - [ISTAT: livelli educativi](#istat-livelli-educativi)

## Dati

### POLITICA

#### Governo - Presidente

- Titolo: Vice Presidenti, Ministri e Sottosegretari
- URL: https://www.governo.it/it/ministri-e-sottosegretari

#### Governo

- Titolo: Vice Presidenti, Ministri e Sottosegretari
- URL: https://www.governo.it/it/ministri-e-sottosegretari

#### Camera - Presidente

- Titolo: Il Presidente
- URL: https://presidente.camera.it/presidente/biografia

#### Camera

- Titolo: Dati Camera, persone elette
- URL: https://dati.camera.it/
- Sheet: https://docs.google.com/spreadsheets/d/1-2GFVAfeY3cqCyr7qMZDUThHYT8KUUKM-ro7_NAofbM/edit?gid=1358560610#gid=1358560610
- RAW_DATA: [`camera.csv`](./rawdata/camera.csv)

#### Senato - Presidente

- Titolo: Il Presidente del Senato
- URL: https://www.senato.it/presidente

#### Senato

- Titolo: Dati Senato, persone elette
- URL: https://dati.senato.it/DatiSenato/browse/6?testo_generico=11&legislatura=19
- Sheet: https://docs.google.com/spreadsheets/d/1BqzlfWnXdwvzHGULnN6BljyS2BmCyVfTm7dxA095bcw/edit?gid=1626256383#gid=1626256383
- RAW_DATA: [`senato.csv`](./rawdata/senato.csv)

#### Ambasciate

- Titolo: Rete diplomatica
- URL: https://www.esteri.it/it/ministero/struttura/laretediplomatica/
- Sheet: https://docs.google.com/spreadsheets/d/1lNlN3TaCre1A17xXB5sXbKt_IALycdvdOB3-3XIwxsE/edit?gid=2128522936#gid=2128522936
- RAW_DATA: [`ambasciate.csv`](../ambasciate/processing/ambasciate.csv)

#### Sindaci

- Titolo: Amministratori locali e regionali in carica
- URL: https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica
- Data_URL: https://dait.interno.gov.it/documenti/sindaciincarica.csv
- Sheet: https://docs.google.com/spreadsheets/d/142VvQIr3Zr7DGbvgRtJyJ4dlypKfX40l4P9mILYSlgw/edit?gid=2135229812#gid=2135229812
- RAW_DATA: [`sindaciincarica.csv`](../../dati/amministazioni-italiane/processing/sindaciincarica.csv)
  - Note: modificato encoding da `ISO8859-1` a `UTF-8`, cambiato separatore di campo da `;` a `,`, inserite colonne `data_elezione_ISO` e `data_entrata_in_carica_ISO` in formato `YYYY-MM-DD`, rimosse righe di intestazione superflue, aggiunta colonna `CODICE_ISTAT` con codice ISTAT del comune.

#### Consiglio e Giunta dei Comuni

- Titolo: Amministratori locali e regionali in carica
- URL: https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica
- Data_URL: https://dait.interno.gov.it/documenti/ammcom.csv
- Sheet: https://docs.google.com/spreadsheets/d/1VjVIUNolDgiuz4l465_LBSCPfVEoB2mr1DN5A8LdekM/edit?gid=1542105272#gid=1542105272
- RAW_DATA: [`ammcom.csv`](../../dati/amministazioni-italiane/processing/ammcom.csv)
  - Note: modificato encoding da `ISO8859-1` a `UTF-8`, cambiato separatore di campo da `;` a `,`, inserite colonne `data_elezione_ISO` e `data_entrata_in_carica_ISO` in formato `YYYY-MM-DD`, rimosse righe di intestazione superflue, aggiunta colonna `CODICE_ISTAT` con codice ISTAT del comune.

#### Presidenza Regione, Giunta Regione e Consiglio Regione

- Titolo: Amministratori locali e regionali in carica
- URL: https://dait.interno.gov.it/elezioni/open-data/amministratori-locali-e-regionali-in-carica
- Data_URL: https://dait.interno.gov.it/documenti/ammreg.csv
- Sheet: https://docs.google.com/spreadsheets/d/1UbTWqyzGroZ8o9ILbGdjFLpVzrT9Uz4IYwVrlsfPIwY/edit?gid=598757995#gid=598757995
- RAW_DATA: [`ammreg.csv`](../../dati/amministazioni-italiane/processing/ammreg.csv)
  - Note: modificato encoding da `ISO8859-1` a `UTF-8`, cambiato separatore di campo da `;` a `,`, inserite colonne `data_elezione_ISO` e `data_entrata_in_carica_ISO` in formato `YYYY-MM-DD`, rimosse righe di intestazione superflue

### ECONOMIA

#### MEF

- Titolo: Elenco delle partecipazioni dirette del Ministero dell'Economia e delle Finanze
- URL: https://www.de.mef.gov.it/it/attivita_istituzionali/partecipazioni/elenco_partecipazioni/
- Sheet: https://docs.google.com/spreadsheets/d/1HsSbItV2itCOhIWEy58L4U_VL3woJ-7TWG2h9HYEQ6w/edit?gid=0#gid=0
- RAW_DATA: [`mef.csv`](./rawdata/mef.csv)

#### Società quotate - CEO e Presidente

- Titolo: Società quotate - CEO e Presidente
- URL: https://mercati.ilsole24ore.com/azioni/classifiche/capitalizzazione-piazza-affari
- Sheet: https://docs.google.com/spreadsheets/d/1xomIYXvtBw0ShaXBDtC0Nj-iWgTXXqFSkW5ueKOyBF4/edit?gid=0#gid=0
- RAW_DATA: [`borsa_milano.csv`](./rawdata/borsa_milano.csv)

#### Gruppi bancari

- Titolo: Gruppi bancari
- Sheet: https://docs.google.com/spreadsheets/d/1xomIYXvtBw0ShaXBDtC0Nj-iWgTXXqFSkW5ueKOyBF4/edit?gid=1598042960#gid=1598042960
- RAW_DATA: [`gruppi_bancari_ita.csv`](./rawdata/gruppi_bancari_ita.csv)

#### Gruppi Tech

- Titolo: Gruppi Tech
- URL: https://www.businessintelligencegroup.it/le-aziende-tecnologiche-ditalia-il-segmento-hi-tech-di-euronext/
- Sheet: https://docs.google.com/spreadsheets/d/1xomIYXvtBw0ShaXBDtC0Nj-iWgTXXqFSkW5ueKOyBF4/edit?gid=1237166295#gid=1237166295
- RAW_DATA: [`tech_ita.csv`](./rawdata/tech_ita.csv)

### MEDIA

#### Quotidiani

- Titolo: Quotidiani per tiratura
- URL: https://www.agcom.it/sites/default/files/media/allegato/2024/Pubblicazione_Report_Tirature_2023%20%281%29%20copia.pdf
- Sheet: https://docs.google.com/spreadsheets/d/1G4j0CDqW-Hpgg7RzHJ5husdxLW4RSIMW8_Wnl0PFLgg/edit?gid=0#gid=0
- RAW_DATA: [`quotidiani_x_tiratura.csv`](./rawdata/quotidiani_x_tiratura.csv)

#### TG

- Titolo: Direzione telegiornali
- Sheet: https://docs.google.com/spreadsheets/d/1G4j0CDqW-Hpgg7RzHJ5husdxLW4RSIMW8_Wnl0PFLgg/edit?gid=501240274#gid=501240274
- RAW_DATA: [`tg.csv`](./rawdata/tg.csv)

#### Agenzie di stampa

- Titolo: Agenzie di stampa
- URL: https://it.wikipedia.org/wiki/Agenzia_di_stampa
- Sheet: https://docs.google.com/spreadsheets/d/1G4j0CDqW-Hpgg7RzHJ5husdxLW4RSIMW8_Wnl0PFLgg/edit?gid=773087133#gid=773087133
- RAW_DATA: [`agenzie_stampa.csv`](./rawdata/agenzie_stampa.csv)

### SOCIETÀ

#### Atenei

- Titolo: Elenco Rettori
- URL: https://www.crui.it/atenei-e-rettori-crui/elenco-rettori.html
- Sheet: https://docs.google.com/spreadsheets/d/1_O5MB3ego_748hL9ejWVzgWve85ubjchbPWmd9gyXnM/edit?gid=0#gid=0
- RAW_DATA: [`universita.csv`](./rawdata/universita.csv)

#### Enti di ricerca

- Titolo: Enti di ricerca pubblici
- URL: https://www.mur.gov.it/it/aree-tematiche/ricerca/il-sistema-della-ricerca/enti-di-ricerca-pubblici
- Sheet: https://docs.google.com/spreadsheets/d/1xvWbU9o1-KnG-O4q7peJ3ZnUROD-iOx1DR6qxZsB5Z4/edit?gid=0#gid=0
- RAW_DATA: [`enti_di_ricerca.csv`](./rawdata/enti_di_ricerca.csv)

#### Autorità indipendenti

- Titolo: Autorità indipendenti
- URL: https://www.senato.it/3222
- Sheet: https://docs.google.com/spreadsheets/d/1RdfZo_4PyewMiGG_JN8x1zatO-UsYyv2YayhMoJ7WaQ/edit?gid=0#gid=0
- RAW_DATA: [`autorità_indipendenti.csv`](./rawdata/autorità_indipendenti.csv)

### CONTESTO

#### Percentuale residenti

- Titolo: Popolazione residente e dinamica della popolazione - Anno 2023
- URL: https://www.istat.it/comunicato-stampa/popolazione-residente-e-dinamica-della-popolazione/

#### ISTAT: livelli educativi

- Titolo: Livelli di istruzione e ritorni occupazionali | anno 2023
- URL: https://www.istat.it/wp-content/uploads/2024/07/REPORT-livelli-istruzione.pdf
