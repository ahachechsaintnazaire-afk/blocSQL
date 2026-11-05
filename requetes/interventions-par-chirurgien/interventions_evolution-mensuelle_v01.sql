/*==============================================================================
 REQUETE      : interventions_evolution-mensuelle_v01
 OBJECTIF     : Extraire le nombre d'interventions par annee, mois, specialite,
                praticien et motif (ou acte), en lignes a plat, pour calculer
                des evolutions (mois/mois, annee/annee) dans Excel (TCD).
 CONTEXTE     : Suivi d'activite du bloc. Une ligne par combinaison
                annee / mois / specialite / praticien / motif.
 BASE         : Bloc (Oracle) - blocact.exe, requeteur SQL (Maintenance)
 AUTEUR       : Aurelien Hache (avec Claude)
 CREEE LE     : 2026-11-05
 DERNIERE MAJ : 2026-11-05

 TABLES UTILISEES
   INTVTION  : intervention tracee (I1CLEUNIK, R0CLEUNIK, MTCLEUNIK = motif, DUREEINTVTION)
   RDV       : date de l'intervention (DATERDV), praticien (I0CLEUNIK), acte (P2CLEUNIK)
   INTERVNT  : praticien (NOMINTER, PRENOMINTER, SPCLEUNIK)
   SPECIAL   : specialite du praticien (LIBELSPEC)
   MOTIF     : motif de l'intervention (MTCLEUNIK, CODEMT, LIBELMT)
   PROTOBL   : libelle de l'acte (NOMPROTO) - Q2 uniquement

 PARAMETRES (ecrits en dur dans la requete, a modifier avant execution)
   Date debut  : DATE '2023-01-01' - debut de periode
   Date fin    : DATE '2026-11-01' - fin de periode (exclue)

 COLONNES DE SORTIE
   ANNEE, MOIS (01 a 12), SPECIALITE, PRATICIEN (NOM PRENOM), MOTIF (ou ACTE en Q2),
   NB_INTERVENTIONS, DUREE_TOTALE (somme de INTVTION.DUREEINTVTION, unite a confirmer)

 LOGIQUE
   1. INTVTION -> RDV (date, praticien) -> INTERVNT -> SPECIAL.
   2. Motif : INTVTION.MTCLEUNIK -> MOTIF.LIBELMT (« Non renseigne » si vide).
   3. Agregation par annee, mois, specialite, praticien, motif.

 POINTS D'ATTENTION
   - Date retenue : RDV.DATERDV (date planifiee du RDV).
   - Le motif vient de INTVTION.MTCLEUNIK ; si la colonne est peu renseignee,
     utiliser Q2 (par acte) ou verifier le sens de MOTIF.TYPEMT.
   - RDV.I0CLEUNIK = praticien du RDV (a confirmer : chirurgien ou 1er intervenant).
   - Les mois sans intervention n'ont pas de ligne : completer dans Excel.
   - DUREEINTVTION : unite non verifiee (minutes probable).

 PERFORMANCES
   Non mesurees ; reduire la periode si la requete est lente.

 HISTORIQUE
   2026-11-05 | AH/Claude | Creation (a tester)

 REGLES DU REQUETEUR BLOC (voir docs/CONVENTIONS.md, section 8)
   - La requete commence par SELECT, sans commentaire devant.
   - JAMAIS de WITH, pas de point-virgule final (ORA-00933), une seule requete par fenetre.
==============================================================================*/

-- ---------------------------------------------------------------------------
-- Q1 - Interventions par annee, mois, specialite, praticien et motif
-- Statut : a tester
-- Note   : periode 2023-01-01 a 2026-10-31
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      TO_CHAR(R.DATERDV, 'YYYY')                AS ANNEE
    , TO_CHAR(R.DATERDV, 'MM')                  AS MOIS
    , NVL(SP.LIBELSPEC, 'Non renseignee')       AS SPECIALITE
    , IT.NOMINTER || ' ' || IT.PRENOMINTER      AS PRATICIEN
    , NVL(M.LIBELMT, 'Non renseigne')           AS MOTIF
    , COUNT(DISTINCT I.I1CLEUNIK)               AS NB_INTERVENTIONS
    , SUM(I.DUREEINTVTION)                      AS DUREE_TOTALE
FROM   INTVTION I
JOIN   RDV R      ON R.R0CLEUNIK  = I.R0CLEUNIK
JOIN   INTERVNT IT ON IT.I0CLEUNIK = R.I0CLEUNIK
LEFT   JOIN SPECIAL SP ON SP.SPCLEUNIK = IT.SPCLEUNIK
LEFT   JOIN MOTIF M    ON M.MTCLEUNIK  = I.MTCLEUNIK
WHERE  R.DATERDV >= DATE '2023-01-01'
  AND  R.DATERDV <  DATE '2026-11-01'
GROUP  BY TO_CHAR(R.DATERDV, 'YYYY'), TO_CHAR(R.DATERDV, 'MM'), SP.LIBELSPEC, IT.NOMINTER, IT.PRENOMINTER, M.LIBELMT
ORDER  BY ANNEE, MOIS, SPECIALITE, PRATICIEN, MOTIF

-- ---------------------------------------------------------------------------
-- Q2 - Interventions par annee, mois, specialite, praticien et acte
-- Statut : a tester
-- Note   : meme perimetre que Q1, acte principal du RDV a la place du motif
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      TO_CHAR(R.DATERDV, 'YYYY')                AS ANNEE
    , TO_CHAR(R.DATERDV, 'MM')                  AS MOIS
    , NVL(SP.LIBELSPEC, 'Non renseignee')       AS SPECIALITE
    , IT.NOMINTER || ' ' || IT.PRENOMINTER      AS PRATICIEN
    , NVL(PB.NOMPROTO, 'Non renseigne')         AS ACTE
    , COUNT(DISTINCT I.I1CLEUNIK)               AS NB_INTERVENTIONS
    , SUM(I.DUREEINTVTION)                      AS DUREE_TOTALE
FROM   INTVTION I
JOIN   RDV R      ON R.R0CLEUNIK  = I.R0CLEUNIK
JOIN   INTERVNT IT ON IT.I0CLEUNIK = R.I0CLEUNIK
LEFT   JOIN SPECIAL SP ON SP.SPCLEUNIK = IT.SPCLEUNIK
LEFT   JOIN PROTOBL PB ON PB.P2CLEUNIK = R.P2CLEUNIK
WHERE  R.DATERDV >= DATE '2023-01-01'
  AND  R.DATERDV <  DATE '2026-11-01'
GROUP  BY TO_CHAR(R.DATERDV, 'YYYY'), TO_CHAR(R.DATERDV, 'MM'), SP.LIBELSPEC, IT.NOMINTER, IT.PRENOMINTER, PB.NOMPROTO
ORDER  BY ANNEE, MOIS, SPECIALITE, PRATICIEN, ACTE
