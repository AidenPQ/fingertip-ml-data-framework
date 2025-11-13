# Data policy & layout

This repository **does not version** production CAD or heavy meshes.  
We only keep **tiny samples** for demos. Production meshes stay **out of git**.

## Rules
- `data/raw/` and `data/processed/` are **ignored** by git (see `.gitignore`).
- `data/CAD/` is the **source tree** used by the initializer. Keep only **very small samples** here.
- `data/samples/` contains demo artifacts (a few tiny `.stl` files, a small JSON catalog).

## Required layout for initialization

The init script walks a **CAD root** (local or SFTP) with this structure:


```text
data/
└─ CAD/
├─ <vendor_1>/
│ ├─ <family_A>/
│ │ ├─ part_001.stl
│ │ └─ part_002.stl
│ └─ <family_B>/
│ └─ part_003.stl
└─ <vendor_2>/
└─ <family_C>/
└─ part_004.stl
```

---


- **vendor**: data source (e.g., `Fabwave`, `ABC`)
- **family**: category (e.g., `Pipes`, `Sheets`, `Grids`)
- **part_xxx.stl**: STL file (pivot format)

> The **root path** is provided by the `CAD_ROOT` environment variable (see `.env.example`).  
> MongoDB indexes **metadata + references** (relative path), **not** meshes.

## Suggested samples

```text
data/
├─ CAD/
│ └─ Fabwave/
│ └─ Pipes/
│ ├─ elbow_20_sample.stl
│ └─ tee_15_sample.stl
└─ samples/
└─ catalog.json # tiny demo catalog
```

---


Minimal `samples/catalog.json`:
```json
[
  {"vendor": "Fabwave", "family": "Pipes", "name": "elbow_20_sample", "ext": "stl", "tags": ["demo","pipe"]},
  {"vendor": "Fabwave", "family": "Pipes", "name": "tee_15_sample",   "ext": "stl", "tags": ["demo","pipe"]}
]


Run a first demo

Copy .env.example → .env and set CAD_ROOT=./data/CAD, IS_LOCAL=true.

Install Python deps (tools/python/requirements.txt).

Run python db/examples/init_from_env.py.

Open MongoDB Compass and check that the collection (e.g., CAD.files) has documents.



---

### `db/schemas/README.md`
```markdown
# Mongo document schema (example)

Documents store **metadata** and **references** to CAD files
(relative path from `CAD_ROOT` if local, or remote path if SFTP).  
Meshes are **not** stored in the DB.

## Example document

```json
{
  "_id": "ObjectId",
  "vendor": "Fabwave",
  "family": "Pipes",
  "name": "elbow_20_sample",
  "ext": "stl",
  "storage": {
    "type": "local",
    "root": "./data/CAD",
    "relpath": "Fabwave/Pipes/elbow_20_sample.stl"
  },
  "tags": ["fingertip", "pipe", "demo"],
  "units": "mm",
  "bbox": [[-10.1, -5.0, -2.0], [12.3, 7.4, 3.0]],
  "created_at": "2025-11-07T12:00:00Z",
  "updated_at": "2025-11-07T12:00:00Z"
}
```

---

Recommended fields:

vendor (string): source/provider

family (string): internal category

name (string): part ID without extension

ext (string): file extension (stl, step, …)

storage (object):

type: "local" or "sftp"

root: root folder (e.g., ./data/CAD or /mnt/share/...)

relpath: path relative to root

tags (array[string]): for fast searching

units (string): target units after import (e.g., mm)

bbox (2×3 array[number]): bounding box (optional)

created_at / updated_at (ISO8601)


---

