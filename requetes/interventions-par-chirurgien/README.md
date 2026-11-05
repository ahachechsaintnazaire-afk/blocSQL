# interventions-par-chirurgien

Activité du bloc : nombre d'interventions par spécialité, chirurgien et libellé d'acte.

## Contexte

Première approche de l'activité du bloc. Modèle de liaison : `RDV` (chirurgien `I0CLEUNIK`, acte principal `P2CLEUNIK`) → `INTERVNT` (nom) ; spécialité = `PROTOBL.SPCLEUNIK` → `SPECIAL` (libellé) ; libellé de l'acte dans `PROTOBL.NOMPROTO` ; intervention réelle = ligne dans `INTVTION` (`R0CLEUNIK`). Le premier essai du 2026-11-05 a échoué en ORA-00933 à cause du point-virgule final (retiré).

## Fichiers

- `interventions_par-chirurgien_v01.sql` : totaux par spécialité, chirurgien, acte.
- `interventions_detail-par-intervention_v02.sql` : une ligne par intervention pour faire les bilans sous Excel.
- `interventions_evolution-mensuelle_v01.sql` : données à plat par année, mois, spécialité, praticien, motif (Q1) ou acte (Q2), pour calculer des évolutions dans Excel.

## Requetes contenues (par_chirurgien_v01)

| Requete | Statut |
|---|---|
| Q1. Répartition des RDV par état (valeurs de `ETATRDV`, avec/sans `INTVTION`) | à tester |
| Q2. Interventions par spécialité, chirurgien et acte | à retester (ORA-00933 corrigé) |
| Q3. Synthèse par spécialité (interventions, chirurgiens, actes distincts) | à tester |
| Q4. Contrôle 2026 : RDV et interventions par praticien, spécialité et acte, sans filtre INTVTION | à tester |
| `interventions_detail-par-intervention_v02.sql` Q1. Une ligne par intervention (dates, salle, praticien, acte, motif, anesthésie), tous états de RDV | à tester |

## Utilisation

Lancer Q1 d'abord pour identifier les états de RDV correspondant à une intervention réalisée, puis ajuster le filtre de Q2/Q3 si besoin. Modifier les dates en dur avant exécution. Copier dans le requêteur **uniquement** le bloc sous « A COPIER DANS LE REQUETEUR » (une requête par fenêtre).

## Points ouverts

- La spécialité retenue est celle de l'**acte** (`PROTOBL.SPCLEUNIK`) : celle des praticiens n'est pas renseignée. À rebasculer sur `INTERVNT.SPCLEUNIK` quand le paramétrage sera corrigé (Q4 compare les deux).
- Les actes secondaires (`RDVPRO`) et les intervenants multiples (`RDVINT`) ne sont pas pris en compte.
