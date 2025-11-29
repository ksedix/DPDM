import os
import json

root = '/mimer/NOBACKUP/groups/naiss2024-22-432/cinic10/train_valid'
class_names = sorted(os.listdir(root))
class_to_idx = {name: idx for idx, name in enumerate(class_names)}

labels = []
for class_name in class_names:
    class_dir = os.path.join(root, class_name)
    for fname in os.listdir(class_dir):
        if fname.endswith('.png'):
            rel_path = os.path.join(class_name, fname)
            labels.append([rel_path, class_to_idx[class_name]])

with open(os.path.join(root, 'dataset.json'), 'w') as f:
    json.dump({'labels': labels}, f)
