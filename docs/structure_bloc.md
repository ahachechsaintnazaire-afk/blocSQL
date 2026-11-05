# Structure du logiciel Bloc - tables utiles et liaisons déduites

Base Oracle du logiciel Bloc (blocact.exe, schéma applicatif `P_PHBLOCCS`, base `PHBLOCPR`). Détail des colonnes : `schema_bloc_oracle.md` (888 tables, 9 178 colonnes).

**Avertissement** : l'export ne contient ni clé étrangère ni contrainte. Les liaisons ci-dessous sont **déduites des noms de colonnes** (une colonne `XXCLEUNIK` qui est la première colonne d'une autre table). Elles sont à confirmer par requête avant de s'y fier.

## 1. Constat général

- Le schéma contient le modèle Pharma complet (COMMANDE, PRESCRIP, FOURNIS, ARMOIRE...) : seule une petite partie est utilisée par le Bloc.
- **`PRODUIT` est vide** (constaté le 2026-11-05) : le catalogue produit, les lots et la traçabilité des DM sont dans Pharma. Les colonnes `PRCLEUNIK` du Bloc (`DETINTER`, `TRACATMP`, `SUIVI_POSE`, `DETPROTO`) pointent vers un produit résolu côté Pharma.
- `TRACA` est un **journal d'audit** (utilisateur, opération, poste), sans produit ni lot.
- Les clés suivent la convention `XXCLEUNIK` (NUMBER 10). Les tables récentes utilisent `ID` / `ID_<TABLE>` et les colonnes d'audit `U_CREAT`, `D_CREAT`, `H_CREAT`, `U_MAJ`, `D_MAJ`, `H_MAJ`.

## 2. Modèle de liaisons du bloc (déduit)

```
BLOC (B0CLEUNIK)
  └─< SALLE (SACLEUNIK, B0CLEUNIK)
          └─< RDV (R0CLEUNIK, SACLEUNIK, I0CLEUNIK, P2CLEUNIK, PACLEUNIK, CPCLEUNIK, TACLEUNIK)
                 │     DATERDV, HRDV, HFINRDV, ETATRDV, DUREERDV
                 ├── I0CLEUNIK ──> INTERVNT (I0CLEUNIK, SPCLEUNIK, TYPEINTER) ──> SPECIAL (SPCLEUNIK, LIBELSPEC)
                 ├── P2CLEUNIK ──> PROTOBL (P2CLEUNIK, NOMPROTO, SPCLEUNIK)   [acte principal]
                 ├── PACLEUNIK ──> PATIENT (PACLEUNIK)
                 ├── TACLEUNIK ──> TYPANEST (TACLEUNIK)                        [type d'anesthésie]
                 ├─< RDVPRO (R0CLEUNIK, P2CLEUNIK)                             [actes du RDV, dont secondaires]
                 ├─< RDVINT (R0CLEUNIK, I0CLEUNIK, FCCLEUNIK)                  [intervenants du RDV, fonction]
                 └─< INTVTION (I1CLEUNIK, R0CLEUNIK)                           [intervention tracée]
                         ├─< DETINTER (D2CLEUNIK, I1CLEUNIK, R0CLEUNIK, PRCLEUNIK, QTEUTILDETINTER)
                         ├─< TRACATMP (PRCLEUNIK, I1CLEUNIK, LOCLEUNIK, NUMEROLOT, DATEPEREMP, QTE)
                         └─< SSPI (SSPICLEUNIK, I1CLEUNIK)                     [salle de surveillance post-interventionnelle]
```

Notes :
- `RDV` est le planning ; `INTVTION` ajoute le déroulé réel (heures réelles `HDEBREELLE`/`HFINREELLE`, durée, comptage).
- `RDVPRIS` est l'historique des prises de RDV (créneaux, motifs d'annulation `MARCLEUNIK`).
- `INTERV_PERS` (+ `FCTSALLE`, `CATFCT`) : planning et fonction du personnel. `DISPOINTERVNT` : disponibilités des intervenants.
- Spécialité : portée par l'intervenant (`INTERVNT.SPCLEUNIK`) et par l'acte (`PROTOBL.SPCLEUNIK`). Les deux peuvent différer.

## 3. Tables du périmètre bloc

| Domaine | Tables |
|---|---|
| Structure | `BLOC`, `SALLE`, `SALLE_TYPE`, `SSPI`, `FCTSALLE`, `CATFCT`, `STRUCT_LIT` |
| Planning | `RDV`, `RDVPRIS`, `RDVPRO`, `RDVINT`, `RDV_EXAM`, `RDVCCAM`, `RDVCIM10`, `RDVCDAM`, `RDVNGAP`, `MOTIF`, `MOTIFANNUL`, `QUOTA_PLACE`, `TYPEPLACE` |
| Intervenants | `INTERVNT`, `I0SPECIAL`, `I0SERVICE`, `I0HORAIRES`, `INTERV_PERS`, `DISPOINTERVNT`, `TYPINTERV`, `SPECIAL`, `CATPERSO`, `SALLEPERS` |
| Actes / protocoles | `PROTOBL`, `CPROTOBL`, `DETPROTO`, `PROTINTV`, `PROCCAM`, `PROINT`, `PROINTER`, `CPRPRO`, `P2CATOBLI`, `P2RUBRIK`, `CCAM` |
| Intervention | `INTVTION`, `DETINTER`, `TRACATMP`, `ANEST`, `TYPANEST`, `PA_CHECK_LIST`, `I1CCAM`, `CLPROPRE` |
| Patient / séjour | `PATIENT`, `SEJOUR`, `TYPESEJ` |
| Produits (à vérifier) | `SUIVI_POSE`, `SUIVI_POSE_LOT`, `SUIVI_POSE_CMDE`, `LOTPDT`, `PRODUIT` (vide) |
| Audit | `TRACA`, `UTILISAT` |

## 4. Colonnes clés par table

| Table | Clé | Colonnes utiles |
|---|---|---|
| `BLOC` | `B0CLEUNIK` | `CODEBLOC`, `LIBELBLOC`, `INACT` |
| `SALLE` | `SACLEUNIK` | `NOMSALLE`, `B0CLEUNIK`, `INACTIF`, `ORDRETRI`, `REVEIL` |
| `RDV` | `R0CLEUNIK` | `DATERDV`, `HRDV`, `HFINRDV`, `DUREERDV`, `ETATRDV`, `I0CLEUNIK`, `P2CLEUNIK`, `SACLEUNIK`, `PACLEUNIK`, `AMBULATOIRE`, `DEPAS` |
| `INTVTION` | `I1CLEUNIK` | `R0CLEUNIK`, `HDEBINTVTION`, `HFININTVTION`, `HDEBREELLE`, `HFINREELLE`, `DUREEINTVTION`, `ORDREPASS`, `CODEURG`, `NOCOMPTAGE` |
| `INTERVNT` | `I0CLEUNIK` | `NOMINTER`, `PRENOMINTER`, `TYPEINTER`, `SPCLEUNIK`, `CODERPPS`, `INACTIF` |
| `SPECIAL` | `SPCLEUNIK` | `CODESPEC`, `LIBELSPEC`, `INACT` |
| `PROTOBL` | `P2CLEUNIK` | `NOMPROTO`, `SPCLEUNIK`, `DUREEPROTO`, `CODESSPROTO`, `CODENGAP1`, `INACTIF`, `PROTOPRINCIPAL` |
| `DETINTER` | `D2CLEUNIK` | `I1CLEUNIK`, `R0CLEUNIK`, `PRCLEUNIK`, `QTEUTILDETINTER`, `TYPEDETINTER`, `ANEST` |
| `TRACATMP` | (`PRCLEUNIK`, `I1CLEUNIK`) | `NUMEROLOT`, `DATEPEREMP`, `QTE`, `TYPETRAC`, `LOCLEUNIK`, `POSDETINTER` |
| `PATIENT` | `PACLEUNIK` | `DOSSIER`, `NOMPAT`, `PRENOM`, `DATENAIS`, `SEXE` |

## 5. Points à vérifier

- Valeurs de `RDV.ETATRDV` et de `INTERVNT.TYPEINTER` (voir `requetes/interventions-par-chirurgien/`).
- Volumétrie réelle de `DETINTER`, `TRACATMP`, `SUIVI_POSE`, `LOTPDT` (voir `requetes/diagnostic/`).
- Si `RDV.I0CLEUNIK` désigne le chirurgien ou le premier intervenant planifié (comparer avec `RDVINT` et `TYPINTERV`).

## 6. Informations manquantes

Clés étrangères et contraintes, index, vues, séquences et triggers, valeurs codées, volumétrie.
