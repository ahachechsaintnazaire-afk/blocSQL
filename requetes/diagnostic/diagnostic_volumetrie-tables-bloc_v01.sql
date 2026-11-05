/*==============================================================================
 REQUETE      : diagnostic_volumetrie-tables-bloc_v01
 OBJECTIF     : Savoir quelles tables du bloc sont reellement alimentees
                (nombre de lignes) avant de batir une requete dessus.
 CONTEXTE     : Le schema Bloc contient le modele Pharma complet ; PRODUIT est
                vide. Verifier ou se trouvent les donnees de consommation et de
                tracabilite des DM (DETINTER, TRACATMP, SUIVI_POSE, LOTPDT).
 BASE         : Bloc (Oracle) - blocact.exe, requeteur SQL (Maintenance)
 AUTEUR       : Aurelien Hache (avec Claude)
 CREEE LE     : 2026-11-05
 DERNIERE MAJ : 2026-11-05

 TABLES UTILISEES
   DETINTER, TRACATMP, SUIVI_POSE, SUIVI_POSE_LOT, LOTPDT, PRODUIT,
   INTVTION, RDV, SALLE, INTERVNT : comptage de lignes (et de produits distincts)

 PARAMETRES
   Aucun.

 COLONNES DE SORTIE
   TABLE_BLOC : nom de la table
   NB_LIGNES  : nombre de lignes
   NB_PDT     : nombre de produits distincts (PRCLEUNIK), vide si non applicable

 LOGIQUE
   UNION ALL de comptages simples, une ligne par table.

 POINTS D'ATTENTION
   - Un NB_LIGNES a 0 sur DETINTER/TRACATMP/SUIVI_POSE signifie qu'aucune
     tracabilite DM n'est stockee dans le Bloc.
   - Si DETINTER est alimentee, PRCLEUNIK est resolu cote Pharma (PRODUIT vide ici).

 PERFORMANCES
   Comptages complets : rapides sauf grosses tables ; a lancer hors heures de pointe.

 HISTORIQUE
   2026-11-05 | AH/Claude | Creation (a tester)

 REGLES DU REQUETEUR BLOC (voir docs/CONVENTIONS.md, section 8)
   - La requete commence par SELECT, sans commentaire devant.
   - JAMAIS de WITH, pas de point-virgule final (ORA-00933), une seule requete par fenetre.
==============================================================================*/

-- ---------------------------------------------------------------------------
-- Q1 - Volumetrie des tables cles du bloc
-- Statut : a tester
-- Note   : PRODUIT vide constate le 2026-11-05
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT 'DETINTER' AS TABLE_BLOC, COUNT(*) AS NB_LIGNES, COUNT(DISTINCT D.PRCLEUNIK) AS NB_PDT FROM DETINTER D WHERE D.PRCLEUNIK IS NOT NULL
UNION ALL
SELECT 'TRACATMP', COUNT(*), COUNT(DISTINCT T.PRCLEUNIK) FROM TRACATMP T
UNION ALL
SELECT 'SUIVI_POSE', COUNT(*), COUNT(DISTINCT SP.PRCLEUNIK) FROM SUIVI_POSE SP
UNION ALL
SELECT 'SUIVI_POSE_LOT', COUNT(*), NULL FROM SUIVI_POSE_LOT
UNION ALL
SELECT 'LOTPDT', COUNT(*), COUNT(DISTINCT LO.PRCLEUNIK) FROM LOTPDT LO
UNION ALL
SELECT 'PRODUIT', COUNT(*), NULL FROM PRODUIT
UNION ALL
SELECT 'INTVTION', COUNT(*), NULL FROM INTVTION
UNION ALL
SELECT 'RDV', COUNT(*), NULL FROM RDV
UNION ALL
SELECT 'SALLE', COUNT(*), NULL FROM SALLE
UNION ALL
SELECT 'INTERVNT', COUNT(*), NULL FROM INTERVNT

-- ---------------------------------------------------------------------------
-- Q2 - Apercu de TRACATMP (lots saisis par intervention)
-- Statut : a tester
-- Note   : a lancer seulement si Q1 donne NB_LIGNES > 0 pour TRACATMP
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      T.I1CLEUNIK
    , T.PRCLEUNIK
    , T.NUMEROLOT
    , T.DATEPEREMP
    , T.QTE
    , T.TYPETRAC
    , T.LOCLEUNIK
    , T.POSDETINTER
FROM   TRACATMP T
WHERE  ROWNUM <= 50
