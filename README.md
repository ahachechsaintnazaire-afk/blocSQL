# blocSQL

Documentation de la base du logiciel de bloc opératoire **Bloc** (blocact.exe, Oracle, schéma `P_PHBLOCCS`, base `PHBLOCPR`) et requêtes SQL associées : activité du bloc (interventions, chirurgiens, spécialités, actes) puis traçabilité des dispositifs médicaux.

Même démarche que les dépôts **PharmaSQL** et **chimioSQL** : la structure de la base est documentée, puis les requêtes s'appuient dessus. Chaque requête est commentée, versionnée et rejouable sans contexte extérieur.

## Organisation

```
blocSQL/
├── README.md
├── CHANGELOG.md                       # historique global des évolutions
├── docs/
│   ├── CONVENTIONS.md                 # règles d'écriture et contraintes du requêteur
│   ├── structure_bloc.md              # tables utiles, clés, modèle de liaisons déduit
│   └── schema_bloc_oracle.md          # schéma Oracle complet (888 tables, 9 178 colonnes)
├── modele/
│   └── TEMPLATE.sql                   # modèle d'en-tête à copier pour toute nouvelle requête
├── outils/
│   └── xlsx_vers_schema_md.py         # régénère schema_bloc_oracle.md depuis l'export xlsx
└── requetes/
    ├── diagnostic/                    # volumétrie des tables, contrôle des données disponibles
    └── interventions-par-chirurgien/  # interventions par spécialité, chirurgien, acte
```

Chaque dossier de requêtes contient un `README.md` (contexte, logique, ordre d'exécution) et les fichiers `.sql`.

## Repères de structure

- Clés primaires `XXCLEUNIK` (`R0CLEUNIK` = RDV, `I1CLEUNIK` = intervention, `I0CLEUNIK` = intervenant, `P2CLEUNIK` = acte, `SACLEUNIK` = salle, `SPCLEUNIK` = spécialité). Tables récentes : `ID` / `ID_<TABLE>`.
- Le schéma contient le **modèle Pharma complet** ; seule une petite partie est alimentée au Bloc. **`PRODUIT` est vide** : produits, lots et traçabilité des DM sont à chercher dans Pharma (dépôt PharmaSQL).
- Chaîne principale : `BLOC` → `SALLE` → `RDV` → `INTVTION` → `DETINTER` / `TRACATMP`. Détail dans `docs/structure_bloc.md`.
- `TRACA` est un journal d'audit (utilisateur, opération), pas une traçabilité de produit.

## Contraintes du requêteur

- **Pas de point-virgule final** (ORA-00933), pas de `WITH`, une requête par fenêtre, la requête commence par `SELECT`.
- Paramètres (dates...) écrits en dur, listés dans l'en-tête du fichier.
- Voir `docs/CONVENTIONS.md`, section 8.

## Principes

- Un fichier `.sql` = un en-tête commenté (voir `modele/TEMPLATE.sql`) + des requêtes, chacune sous une ligne `A COPIER DANS LE REQUETEUR` avec titre, statut et note.
- Statuts : validée / utilisée = résultat confirmé ; « à tester » = non exécutée.
- Aucune donnée patient ni résultat d'extraction dans le dépôt : uniquement du code SQL et de la documentation.

## Informations manquantes

Clés étrangères et contraintes, index, vues, séquences et triggers, valeurs codées (`ETATRDV`, `TYPEINTER`...), volumétrie.

## Sources

Export `tables_BLOC.xlsx` fourni le 2026-11-05 (ALL_TAB_COLUMNS).
