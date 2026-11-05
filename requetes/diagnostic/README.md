# diagnostic

Contrôle des données réellement disponibles dans la base Bloc avant de bâtir des requêtes.

## Fichier

`diagnostic_volumetrie-tables-bloc_v01.sql` - Volumétrie des tables clés du bloc

## Contexte

Le schéma Bloc contient le modèle Pharma complet mais `PRODUIT` est vide (constaté le 2026-11-05). Il faut savoir si la consommation et la traçabilité des DM sont stockées au Bloc (`DETINTER`, `TRACATMP`, `SUIVI_POSE`, `LOTPDT`) ou uniquement dans Pharma.

## Requetes contenues

| Requete | Statut |
|---|---|
| Q1. Nombre de lignes des tables clés (et produits distincts) | à tester |
| Q2. Aperçu de TRACATMP (50 lignes) | à tester |

## Utilisation

Lancer Q1. Si `TRACATMP` ou `DETINTER` sont vides, la traçabilité des DM n'est pas au Bloc. Sinon lancer Q2 et relier à Pharma par `PRCLEUNIK` / `LOCLEUNIK`.
