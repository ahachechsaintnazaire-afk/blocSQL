/*==============================================================================
 REQUETE      : interventions_detail-par-intervention_v01
 OBJECTIF     : Extraire une ligne par intervention (RDV du bloc) avec dates,
                heures, salle, praticien, acte, motif, anesthesie et indicateur
                d'intervention tracee, pour faire les bilans sous Excel.
 CONTEXTE     : Bilan d'activite du bloc. Les regroupements (famille d'acte,
                specialite) seront traites apres extraction ; la specialite des
                praticiens n'etant pas renseignee, la specialite de l'acte est
                fournie (a corriger a la source dans le logiciel).
 BASE         : Bloc (Oracle) - blocact.exe, requeteur SQL (Maintenance)
 AUTEUR       : Aurelien Hache (avec Claude)
 CREEE LE     : 2026-11-05
 DERNIERE MAJ : 2026-11-05

 TABLES UTILISEES
   RDV       : intervention planifiee (R0CLEUNIK, DATERDV, HRDV, HFINRDV, ETATRDV,
               I0CLEUNIK = praticien, P2CLEUNIK = acte, SACLEUNIK = salle, TACLEUNIK = anesthesie)
   INTVTION  : intervention tracee (I1CLEUNIK, R0CLEUNIK, HDEBREELLE, HFINREELLE,
               DUREEINTVTION, MTCLEUNIK = motif, CODEURG) - LEFT JOIN
   INTERVNT  : praticien (NOMINTER, PRENOMINTER, SPCLEUNIK)
   PROTOBL   : acte (NOMPROTO, CODECCAMPROTO, SPCLEUNIK)
   SPECIAL   : specialites (praticien SI, acte SA)
   SALLE, BLOC : salle (NOMSALLE) et bloc (LIBELBLOC)
   MOTIF     : motif de l'intervention (LIBELMT)
   TYPANEST  : type d'anesthesie (LIBELTYPANEST)
   URGENCE   : degre d'urgence (LIBELURG)

 PARAMETRES (ecrits en dur dans la requete, a modifier avant execution)
   Date debut  : DATE '2026-01-01' - debut de periode
   Date fin    : DATE '2026-11-06' - fin de periode (exclue)

 COLONNES DE SORTIE
   DATE_RDV, HEURE_DEBUT, HEURE_FIN, ETAT_RDV, BLOC, SALLE, PRATICIEN,
   SPEC_PRATICIEN, ACTE, CODE_CCAM, SPEC_ACTE, MOTIF, ANESTHESIE, URGENCE,
   HEURE_DEBUT_REELLE, HEURE_FIN_REELLE, DUREE, ID_RDV (R0CLEUNIK),
   ID_INTERVENTION (I1CLEUNIK, vide si le RDV n'a pas de ligne INTVTION)

 LOGIQUE
   1. Une ligne par RDV ; si le RDV a plusieurs lignes INTVTION, une ligne par INTVTION.
   2. LEFT JOIN sur tout le reste : aucune ligne n'est perdue si une information manque.
   3. Aucun filtre sur ETATRDV ni sur INTVTION : le tri se fait dans Excel
      (ID_INTERVENTION vide = RDV sans intervention tracee).

 POINTS D'ATTENTION
   - ETATRDV : valeurs non documentees (voir Q1 de interventions_par-chirurgien_v01).
   - Heures en texte (HRDV, HFINRDV, HDEBREELLE...) : format a verifier ; ne pas
     les convertir en date sans controle.
   - RDV.I0CLEUNIK = praticien du RDV (a confirmer : chirurgien ou 1er intervenant).
     Les intervenants multiples sont dans RDVINT (non repris ici).
   - DUREE = INTVTION.DUREEINTVTION, unite non verifiee.
   - Aucune donnee patient n'est extraite (ajouter PACLEUNIK / PATIENT si besoin).
   - Volume : ~26 000 RDV sur 2026 (a 2026-11-05).

 PERFORMANCES
   Non mesurees. Elargir la periode (2024 ou 2025) pour les evolutions.

 HISTORIQUE
   2026-11-05 | AH/Claude | Creation (a tester)

 REGLES DU REQUETEUR BLOC (voir docs/CONVENTIONS.md, section 8)
   - La requete commence par SELECT, sans commentaire devant.
   - JAMAIS de WITH, pas de point-virgule final (ORA-00933), une seule requete par fenetre.
==============================================================================*/

-- ---------------------------------------------------------------------------
-- Q1 - Une ligne par intervention : dates, salle, praticien, acte, motif, anesthesie
-- Statut : a tester
-- Note   : periode 2026-01-01 a 2026-11-05, tous etats de RDV
-- A COPIER DANS LE REQUETEUR : uniquement le bloc ci-dessous (commence par SELECT)
-- ---------------------------------------------------------------------------
SELECT
      R.DATERDV                            AS DATE_RDV
    , R.HRDV                               AS HEURE_DEBUT
    , R.HFINRDV                            AS HEURE_FIN
    , R.ETATRDV                            AS ETAT_RDV
    , B.LIBELBLOC                          AS BLOC
    , S.NOMSALLE                           AS SALLE
    , IT.NOMINTER || ' ' || IT.PRENOMINTER AS PRATICIEN
    , SI.LIBELSPEC                         AS SPEC_PRATICIEN
    , PB.NOMPROTO                          AS ACTE
    , PB.CODECCAMPROTO                     AS CODE_CCAM
    , SA.LIBELSPEC                         AS SPEC_ACTE
    , M.LIBELMT                            AS MOTIF
    , TA.LIBELTYPANEST                     AS ANESTHESIE
    , U.LIBELURG                           AS URGENCE
    , I.HDEBREELLE                         AS HEURE_DEBUT_REELLE
    , I.HFINREELLE                         AS HEURE_FIN_REELLE
    , I.DUREEINTVTION                      AS DUREE
    , R.R0CLEUNIK                          AS ID_RDV
    , I.I1CLEUNIK                          AS ID_INTERVENTION
FROM   RDV R
LEFT   JOIN INTVTION I  ON I.R0CLEUNIK  = R.R0CLEUNIK
LEFT   JOIN INTERVNT IT ON IT.I0CLEUNIK = R.I0CLEUNIK
LEFT   JOIN SPECIAL SI  ON SI.SPCLEUNIK = IT.SPCLEUNIK
LEFT   JOIN PROTOBL PB  ON PB.P2CLEUNIK = R.P2CLEUNIK
LEFT   JOIN SPECIAL SA  ON SA.SPCLEUNIK = PB.SPCLEUNIK
LEFT   JOIN SALLE S     ON S.SACLEUNIK  = R.SACLEUNIK
LEFT   JOIN BLOC B      ON B.B0CLEUNIK  = S.B0CLEUNIK
LEFT   JOIN MOTIF M     ON M.MTCLEUNIK  = I.MTCLEUNIK
LEFT   JOIN TYPANEST TA ON TA.TACLEUNIK = R.TACLEUNIK
LEFT   JOIN URGENCE U   ON U.CODEURG    = I.CODEURG
WHERE  R.DATERDV >= DATE '2026-01-01'
  AND  R.DATERDV <  DATE '2026-11-06'
ORDER  BY R.DATERDV, R.HRDV, S.NOMSALLE
