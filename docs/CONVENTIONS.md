# Conventions d'écriture des requêtes

## 1. En-tête obligatoire
Copier `modele/TEMPLATE.sql`. Champs : objectif, contexte, tables, paramètres, colonnes de sortie, logique, points d'attention, performances, historique.

## 2. Mise en forme
- Mots-clés SQL en majuscules, noms de tables et colonnes tels que dans le schéma (majuscules).
- Une colonne par ligne dans le SELECT, virgule en début de ligne.
- Alias courts et explicites, identiques d'une requête à l'autre :
  `R` = RDV, `IT` = INTERVNT, `SP` = SPECIAL, `PB` = PROTOBL, `I` = INTVTION, `S` = SALLE, `B` = BLOC,
  `DI` = DETINTER, `TT` = TRACATMP, `PA` = PATIENT, `SJ` = SEJOUR, `LO` = LOTPDT.
- Jointures explicites (`JOIN ... ON`), jamais de jointure implicite dans le WHERE.
- Les sous-requêtes complexes passent en sous-requêtes nommées dans le `FROM` (pas de `WITH`, voir §8), commentées dans l'en-tête.

## 3. Commentaires
- Commentaire de bloc `/* ... */` pour l'en-tête uniquement.
- Au-dessus de chaque requête : titre, `Statut`, `Note` (commentaires `--`), puis la ligne `A COPIER DANS LE REQUETEUR`.
- Tout choix métier non évident est justifié (état de RDV retenu, règle de comptage, exclusion).

## 4. Paramètres
- Écrits en dur dans la requête (pas de `&PARAM` ni `:var`), listés dans l'en-tête avec leur format.
- Dates : `DATE 'AAAA-MM-JJ'` pour les colonnes de type DATE ; voir §5 pour les colonnes texte.

## 5. Pièges connus du schéma (à enrichir)
- Le schéma Bloc est le **schéma complet Pharma** (888 tables : COMMANDE, PRESCRIP, PRODUIT, FOURNIS...), dont seule une petite partie est alimentée. **`PRODUIT` est vide** : produits, lots et traçabilité des DM relèvent de Pharma. Compter les lignes avant de bâtir une requête sur une table.
- Clés techniques `XXCLEUNIK` (R0CLEUNIK = RDV, I1CLEUNIK = intervention, I0CLEUNIK = intervenant, P2CLEUNIK = acte/protocole, SACLEUNIK = salle, B0CLEUNIK = bloc, SPCLEUNIK = spécialité, PACLEUNIK = patient, SECLEUNIK = séjour, PRCLEUNIK = produit, LOCLEUNIK = lot). Voir `docs/structure_bloc.md`.
- Heures stockées en texte (`HDEBINTVTION`, `HRDV`, `HDBT`...) : ne pas les comparer comme des dates.
- Certaines dates sont en `VARCHAR2` (ex. `DISPOINTERVNT.DATEDBT`) : protéger la conversion avec `REGEXP_LIKE` avant `TO_DATE` (sinon ORA-01841).
- `INACT` / `INACTIF` / `B_INACT` : 1 = inactif.
- Aucune clé étrangère déclarée : les liaisons sont déduites des noms de colonnes (`docs/structure_bloc.md`) et à confirmer par requête.

## 6. Tests et validation
- Indiquer dans l'historique la date du dernier test réel et le volume de lignes obtenu (ordre de grandeur).
- Vérifier un total contre une source connue (planning du bloc) avant de diffuser un résultat.

## 7. Historique et versions
- Chaque modification est ajoutée en bas de l'en-tête (`AAAA-MM-JJ | auteur | description`) et dans `CHANGELOG.md`.
- Fichiers : `<theme>_<objet>_vNN.sql`. Nouvelle version majeure = changement de logique ou de colonnes de sortie.
- Commits : message court à l'impératif, préfixé par le thème (`interventions: ajoute le filtre par salle`).

## 8. Contraintes du requêteur du logiciel Bloc (prioritaires sur les règles ci-dessus)
Requêteur : menu Maintenance > Procédures debug (fenêtre `CE_REQUETEURSQL`), même moteur que Pharma.
- **Pas de point-virgule final** : provoque ORA-00933 (« la commande SQL ne se termine pas correctement »). Constaté le 2026-11-05.
- Le texte doit **commencer par SELECT** (un commentaire devant provoque ORA-24374 dans Pharma ; même règle par prudence).
- **Jamais de `WITH`** : traité comme une mise à jour dans Pharma ; sous-requêtes dans le `FROM`.
- Une seule requête par fenêtre ; pas de paramètres `&` ni `:` ; pas de commentaire dans une liste `IN (...)`.
- Oracle est sensible à la casse : `UPPER()` sur les filtres texte.
- UPDATE : validation automatique, donc définitif. Exporter l'état d'avant, tester en base de test.
- Statuts : validée / utilisée / appliquée = résultat confirmé ; sans statut = à retester avant usage.
