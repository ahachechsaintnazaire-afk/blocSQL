#!/usr/bin/env python3
"""Convertit l'export ALL_TAB_COLUMNS du logiciel Bloc (xlsx) en docs/schema_bloc_oracle.md.

Usage : python3 outils/xlsx_vers_schema_md.py tables_BLOC.xlsx docs/schema_bloc_oracle.md

Colonnes attendues dans la 1re feuille : TABLE_NAME, COLUMN_NAME, DATA_TYPE,
DATA_LENGTH, DATA_PRECISION, DATA_SCALE.
Note : l'export d'origine contient un attribut de style corrompu (biltinId) qui
fait echouer openpyxl ; le script corrige une copie temporaire avant lecture.
"""
import sys, zipfile, tempfile, os, shutil
import pandas as pd


def lire(chemin):
    tmp = tempfile.mkdtemp()
    corrige = os.path.join(tmp, "corrige.xlsx")
    with zipfile.ZipFile(chemin) as zin, zipfile.ZipFile(corrige, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename == "xl/styles.xml":
                data = data.replace(b"biltinId", b"builtinId")
            zout.writestr(item, data)
    df = pd.read_excel(corrige)
    shutil.rmtree(tmp)
    return df


def type_court(r):
    t = r.DATA_TYPE
    if t == "NUMBER":
        return "N"
    if t.startswith("VARCHAR2") or t == "CHAR":
        return "V%d" % r.DATA_LENGTH
    if t == "DATE":
        return "D7"
    return t  # CLOB, FLOAT... conserves tels quels


def main(src, dst):
    df = lire(src)
    lignes = [
        "# Schéma Oracle BLOC (logiciel de bloc opératoire) - extrait ALL_TAB_COLUMNS",
        "Format: TABLE: COLONNE type(N=number,V=varchar2+longueur,D=date)",
        "",
        "Source : export fourni le 2026-11-05 (tables_BLOC.xlsx), %d tables, %d colonnes." % (df.TABLE_NAME.nunique(), len(df)),
        "L'ordre des colonnes est celui de l'export. Aucune clé étrangère ni contrainte dans l'export.",
        "",
    ]
    for table, g in df.groupby("TABLE_NAME", sort=True):
        cols = ", ".join("%s %s" % (r.COLUMN_NAME, type_court(r)) for r in g.itertuples())
        lignes.append("%s: %s" % (table, cols))
    with open(dst, "w", encoding="utf-8") as f:
        f.write("\n".join(lignes) + "\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
