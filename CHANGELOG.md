# Changelog

Historique global des évolutions du dépôt. Les détails de chaque requête sont dans son en-tête.

## 2026-11-05
- Spécialité des requêtes d'interventions = spécialité de l'acte (celle des praticiens n'est pas renseignée) ; orthopédie = TRAUMATO.
- Création du dépôt : structure, conventions (contraintes du requêteur Bloc, ORA-00933 si point-virgule final), modèle d'en-tête.
- Schéma Oracle complet du Bloc (888 tables, 9 178 colonnes) dans docs/schema_bloc_oracle.md, avec script de régénération (outils/).
- docs/structure_bloc.md : tables du périmètre bloc, clés, modèle de liaisons déduit des noms de colonnes (à confirmer).
- interventions-par-chirurgien : extraction mensuelle par année, mois, spécialité, praticien, motif ou acte (interventions_evolution-mensuelle_v01). À tester.
- interventions-par-chirurgien : interventions par spécialité, chirurgien et acte (3 requêtes). À tester.
- diagnostic : volumétrie des tables clés (DETINTER, TRACATMP, SUIVI_POSE, LOTPDT, PRODUIT...) pour situer la traçabilité DM. À tester.
