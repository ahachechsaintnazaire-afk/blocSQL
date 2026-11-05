/*==============================================================================
 REQUETE      : <theme>_<objet>_vNN
 OBJECTIF     : <ce que la requete permet de repondre, en une ou deux phrases>
 CONTEXTE     : <qui l'utilise, pour quelle decision, a quelle frequence>
 BASE         : Bloc (Oracle) - blocact.exe, requeteur SQL (Maintenance)
 AUTEUR       : Aurelien Hache (avec Claude)
 CREEE LE     : AAAA-MM-JJ
 DERNIERE MAJ : AAAA-MM-JJ

 TABLES UTILISEES
   <TABLE>   : <role dans la requete, colonnes cles utilisees>
   <TABLE>   : <...>

 PARAMETRES (ecrits en dur dans la requete, a modifier avant execution)
   Date debut  : DATE 'AAAA-MM-JJ' - debut de periode
   Date fin    : DATE 'AAAA-MM-JJ' - fin de periode (exclue)
   <autre>     : <description, valeurs possibles>

 COLONNES DE SORTIE
   <COLONNE>   : <signification, unite>
   <COLONNE>   : <...>

 LOGIQUE
   1. <etape 1 : ce que fait la premiere sous-requete / jointure>
   2. <etape 2>
   3. <agregation finale>

 POINTS D'ATTENTION
   - <valeurs codees utilisees et leur sens>
   - <exclusions volontaires et pourquoi>
   - <pieges : dates en chaine, doublons possibles, tables d'archive annuelles>

 PERFORMANCES
   <duree observee, index utiles, conseils : limiter la periode, etc.>

 HISTORIQUE
   AAAA-MM-JJ | AH/Claude | Creation

 REGLES DU REQUETEUR BLOC
   - La requete commence par SELECT, sans commentaire devant.
   - JAMAIS de WITH (execute comme une mise a jour).
     Utiliser des sous-requetes dans le FROM.
   - Pas de point-virgule final (ORA-00933), une seule requete par fenetre.
   - Copier uniquement le bloc sous "A COPIER DANS LE REQUETEUR".
==============================================================================*/

-- ---------------------------------------------------------------------------
-- Q1 - <titre de la requete>
-- Statut : <validee / utilisee / a retester>
-- Note   : <precisions utiles>
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      B.COLONNE1
    , COUNT(*) AS NB_LIGNES
FROM   (
        SELECT
              T.COLONNE1
            , T.COLONNE2
        FROM   TABLE1 T
        WHERE  T.DATE_COL >= DATE '2025-01-01'
          AND  T.DATE_COL <  DATE '2026-01-01'
       ) B
GROUP  BY B.COLONNE1
ORDER  BY B.COLONNE1
