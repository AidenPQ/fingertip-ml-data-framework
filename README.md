# Fingertip ML Data Framework

**MongoDB-backed CAD data framework** for **ML-based gripper fingertip design** (STL as pivot).  
Tooling in **Python** (DB init/query) and **MATLAB** (query/import homogenization, **auto-repositioning** to a common reference, **boundaries** computation, JSON operations).

> Goal: make CAD collections queriable and ML-ready without shipping heavy geometry through Git history.

---

## Why this exists

- **Flexible schema** for heterogeneous fingertip CAD (vendors, naming, tags).  
- **Decouple storage and compute**: DB stores metadata & references (local or SFTP), not heavy meshes.  
- **Reproducible ingestion**: consistent import, re-meshing/pivot (**STL**), and normalized transforms for downstream ML.

---

## Architecture (high-level)

1) **Ingest & Index**  
   - Scan CAD roots (local or SFTP), compute minimal descriptors, write **MongoDB** documents + fast tags.
2) **Query**  
   - Search by tags/geometry origins/vendor/series; return **paths + transforms** (not the mesh data).
3) **Normalize for ML**  
   - MATLAB utilities: import → **reposition** to common frame → compute **boundaries** → emit **JSON ops**.
4) **Export (optional)**  
   - Derive compact CSV/JSON catalogs for training pipelines.

---

## Repository layout

```text
.
├─ data/                 # no heavy CAD in git; samples only
│  └─ CAD/
│     └─ Fabwave/        # vendor/example placeholder
├─ db/
│  └─ examples/          # tiny, no secrets (init/query snippets)
├─ docs/                 # getting-started, figures (to be filled)
├─ research/             # thesis/context (no copyrighted PDFs in literature/)
├─ tools/
│  ├─ python/            # DB mgmt (init/upload/find)
│  └─ matlab/            # query/import, repositioning, boundaries
├─ .editorconfig · .gitattributes · .gitignore
└─ README.md
```

---

## Quickstart

### Prerequisites
- **MongoDB 7.0+** (server + Compass recommandé)
- **Python 3.10+**, **MATLAB R2022b+** (ou plus récent)

### 1) MongoDB up
- Installe et lance MongoDB localement (`mongodb://localhost:27017/`) ou utilise une instance distante.
- Ouvre **MongoDB Compass** pour vérifier la connexion et visualiser DB/collections.

### 2) Python tools
```bash
cd tools/python
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate
pip install -r requirements.txt
```

### 3) First DB init (exemple local)
Édite un petit script (voir `db/examples/init_local_example.py`) avec tes chemins :
```python
HOST, PORT, DB, COLL = "localhost", 27017, "CAD", "files"
CAD_ROOT = r"/mnt/cad_root"  # répertoire local contenant tes vendors
# from tools.python.mongodb_management import MongoDBManagement
# mongo = MongoDBManagement(mongo_hostname=HOST, mongo_port=PORT, mongo_dbname=DB, cad_root=CAD_ROOT)
# mongo.initialize_database(dir_name=COLL)  # scan + index des fichiers
```

Exécute-le une fois pour indexer l’arbo CAD (les **meshes ne sont pas stockés** dans la DB, uniquement des **métadonnées + références**).

### 4) MATLAB: query → import → reposition → boundaries
Utilise un squelette type `db/examples/query_examples.m` pour :
- **Query** par `tags`/vendor/série,
- **Import** homogénéisé (unités/orientations),
- **Reposition** vers un repère commun (export d’un **JSON d’opérations**),
- **Boundaries** (calcul et export de limites numériques pour features ML).

> Le dépôt ne contient **ni credentials** ni **gros CAD**. Renseigne tes chemins locaux ou endpoints **SFTP** en dehors du code versionné.

---

## Data policy

- Ne **committe** pas les CAD de production ni des meshes lourds.  
- Conserve uniquement de **petits échantillons synthétiques** sous `data/samples/`.  
- `.gitignore` exclut `data/raw/`, `processed/`, dumps/secrets et binaires volumineux.

---

## About & Topics

- La description (About) et les Topics sont configurés sur GitHub.  
- Tu peux définir **Website** sur `docs/getting-started.md` (une fois créé).

---

## Roadmap (next steps)

- **docs/getting-started.md** : installation (Mongo/Compass), env Python/MATLAB, local vs SFTP, exécuter les exemples.  
- **tools/python/** : modules à ajouter
  - `mongodb_management.py` (connect/init/insert/find/update)
  - `cad_scanner.py` (scan vendors, détection fichiers, descripteurs simples)
  - `schemas.py` (structures de docs d’exemple / validation)
- **tools/matlab/** :
  - `QueryManager.m` (wrap des find)
  - `ImportData.m` (import normalisé)
  - `Reposition.m` (transforme vers repère canonique → JSON ops)
  - `Boundaries.m` (calcul/export des limites)
- **db/examples/** :
  - scripts Python (init local / listing SFTP) + script MATLAB (query→import→reposition→boundaries) **sans secrets**
- **data/samples/** :
  - 2–3 **STL minuscules** + un **catalog JSON** minimal
- **docs/** :
  - diagrammes (ingest → query → normalize) + 1–2 captures Compass
- **README badges** (optionnel) :
  - version Python, note “no license”
- **Release v0.1.0** :
  - tag + notes (squelette + examples + docs OK)

---

## Reuse

**No license granted.** Tous droits réservés par l’auteur.  
Ouvre une **Issue** pour demander l’autorisation de réutiliser du code, des schémas ou la méthode.

---

## Cite

Si ce framework t’a été utile :

**Ngandjui Tiako, P. Q.** (2025). *Fingertip ML Data Framework (MongoDB + Python/MATLAB).* Repository: `AidenPQ/fingertip-ml-data-framework`.

