/*==============================================================================
 REQUETE      : interventions_par-chirurgien_v01
 OBJECTIF     : Compter les interventions realisees au bloc par specialite,
                par chirurgien et par libelle d'acte, sur une periode.
 CONTEXTE     : Premiere approche de l'activite du bloc (logiciel Bloc, base
                Oracle PHBLOC). Sert a se faire une idee du volume et du
                catalogue d'actes avant de relier la tracabilite des DM.
 BASE         : Bloc (Oracle) - blocact.exe, requeteur SQL (menu Maintenance)
 AUTEUR       : Aurelien Hache (avec Claude)
 CREEE LE     : 2026-11-05
 DERNIERE MAJ : 2026-11-05

 TABLES UTILISEES
   RDV       : rendez-vous / intervention planifiee (R0CLEUNIK, I0CLEUNIK = chirurgien,
               P2CLEUNIK = acte principal, DATERDV, ETATRDV, SACLEUNIK = salle)
   INTERVNT  : intervenants (I0CLEUNIK, NOMINTER, PRENOMINTER, SPCLEUNIK = specialite)
   SPECIAL   : specialites (SPCLEUNIK, LIBELSPEC)
   PROTOBL   : actes / protocoles du bloc (P2CLEUNIK, NOMPROTO = libelle, SPCLEUNIK)
   INTVTION  : intervention effectivement tracee (I1CLEUNIK, R0CLEUNIK -> RDV)

 PARAMETRES (ecrits en dur dans la requete, a modifier avant execution)
   Date debut  : DATE '2026-01-01' - debut de periode
   Date fin    : DATE '2026-11-01' - fin de periode (exclue)

 COLONNES DE SORTIE
   SPECIALITE, CHIRURGIEN (NOM PRENOM), ACTE (libelle), NB_INTERVENTIONS

 LOGIQUE
   1. RDV -> INTERVNT (chirurgien) -> SPECIAL (specialite du chirurgien).
   2. RDV -> PROTOBL (libelle de l'acte principal).
   3. Seuls les RDV ayant une ligne INTVTION sont comptes (intervention reelle).
   4. Agregation par specialite / chirurgien / acte.

 POINTS D'ATTENTION
   - La specialite est celle de l'intervenant (INTERVNT.SPCLEUNIK), pas celle de l'acte.
   - RDV.P2CLEUNIK = acte principal ; les actes secondaires sont dans RDVPRO.
   - Les valeurs de ETATRDV ne sont pas encore documentees : voir Q1.
   - Le filtre EXISTS sur INTVTION suppose qu'une intervention realisee y a une ligne,
     a verifier avec Q1 (colonne AVEC_INTVTION).
   - PRODUIT est vide dans la base Bloc : les produits restent dans Pharma.

 PERFORMANCES
   Non mesurees.

 HISTORIQUE
   2026-11-05 | AH/Claude | Creation. Premier essai en erreur ORA-00933 (point-virgule final).

 REGLES DU REQUETEUR BLOC (voir docs/CONVENTIONS.md, section 8)
   - La requete commence par SELECT, sans commentaire devant.
   - JAMAIS de WITH, pas de point-virgule final (ORA-00933), une seule requete par fenetre.
   - Copier uniquement le bloc sous "A COPIER DANS LE REQUETEUR".
==============================================================================*/

-- ---------------------------------------------------------------------------
-- Q1 - Repartition des RDV par etat (pour identifier les valeurs de ETATRDV)
-- Statut : a tester
-- Note   : AVEC_INTVTION = nombre de RDV de cet etat ayant une ligne INTVTION
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      R.ETATRDV
    , COUNT(*)            AS NB_RDV
    , COUNT(I.I1CLEUNIK)  AS AVEC_INTVTION
    , MIN(R.DATERDV)      AS DU
    , MAX(R.DATERDV)      AS AU
FROM   RDV R
LEFT   JOIN INTVTION I ON I.R0CLEUNIK = R.R0CLEUNIK
GROUP  BY R.ETATRDV
ORDER  BY R.ETATRDV

-- ---------------------------------------------------------------------------
-- Q2 - Interventions par specialite, chirurgien et acte
-- Statut : a retester (erreur ORA-00933 du 2026-11-05 due au point-virgule final)
-- Note   : periode 2026-01-01 a 2026-10-31
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      SP.LIBELSPEC                         AS SPECIALITE
    , IT.NOMINTER || ' ' || IT.PRENOMINTER AS CHIRURGIEN
    , PB.NOMPROTO                          AS ACTE
    , COUNT(DISTINCT R.R0CLEUNIK)          AS NB_INTERVENTIONS
FROM   RDV R
JOIN   INTERVNT IT ON IT.I0CLEUNIK = R.I0CLEUNIK
LEFT   JOIN SPECIAL SP ON SP.SPCLEUNIK = IT.SPCLEUNIK
LEFT   JOIN PROTOBL PB ON PB.P2CLEUNIK = R.P2CLEUNIK
WHERE  R.DATERDV >= DATE '2026-01-01'
  AND  R.DATERDV <  DATE '2026-11-01'
  AND  EXISTS (SELECT 1 FROM INTVTION I WHERE I.R0CLEUNIK = R.R0CLEUNIK)
GROUP  BY SP.LIBELSPEC, IT.NOMINTER, IT.PRENOMINTER, PB.NOMPROTO
ORDER  BY SP.LIBELSPEC, IT.NOMINTER, IT.PRENOMINTER, COUNT(DISTINCT R.R0CLEUNIK) DESC

-- ---------------------------------------------------------------------------
-- Q3 - Synthese par specialite (nombre d'interventions, de chirurgiens, d'actes)
-- Statut : a tester
-- Note   : meme perimetre que Q2
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      SP.LIBELSPEC                 AS SPECIALITE
    , COUNT(DISTINCT R.R0CLEUNIK)  AS NB_INTERVENTIONS
    , COUNT(DISTINCT R.I0CLEUNIK)  AS NB_CHIRURGIENS
    , COUNT(DISTINCT R.P2CLEUNIK)  AS NB_ACTES_DISTINCTS
FROM   RDV R
JOIN   INTERVNT IT ON IT.I0CLEUNIK = R.I0CLEUNIK
LEFT   JOIN SPECIAL SP ON SP.SPCLEUNIK = IT.SPCLEUNIK
WHERE  R.DATERDV >= DATE '2026-01-01'
  AND  R.DATERDV <  DATE '2026-11-01'
  AND  EXISTS (SELECT 1 FROM INTVTION I WHERE I.R0CLEUNIK = R.R0CLEUNIK)
GROUP  BY SP.LIBELSPEC
ORDER  BY COUNT(DISTINCT R.R0CLEUNIK) DESC
