import json
from pathlib import Path
import os

source_dir = Path(os.environ["TMPDIR"]) / "ILSVRC/Data/CLS-LOC/train"
synset_file = Path("/mimer/NOBACKUP/groups/naiss2024-22-432/LOC_synset_mapping.txt")
# Map WordNet IDs to labels (chronological order)
synset_to_label = {}
with open(synset_file, "r") as f:
    for idx, line in enumerate(f):
        synset = line.split()[0]
        synset_to_label[synset] = idx
print("Loaded", len(synset_to_label), "synsets")
# Collect image paths and labels
labels = []
for synset_dir in source_dir.iterdir():
    if synset_dir.is_dir():
        label = synset_to_label[synset_dir.name]
        for img_path in synset_dir.glob("*.JPEG"):
            rel_path = str(img_path.relative_to(source_dir))
            labels.append([rel_path, label])
print("Total images collected:", len(labels))
# Save dataset.json
with open(source_dir / "dataset.json", "w") as f:
    json.dump({"labels": labels}, f)
