#!/bin/bash
#SBATCH --job-name=imagenet_process_debug
#SBATCH --gres=gpu:A100:1
#SBATCH --account=C3SE2025-1-14
#SBATCH --time=7-00:00:00
#SBATCH --output=imagenet_process_debug_%j.out
#SBATCH --error=imagenet_process_debug_%j.err

module load CUDA/11.3.1
echo "Loaded CUDA/11.3.1"
source venv-dockhorn/bin/activate
echo "Activated virtual environment"
echo "Temporary directory: $TMPDIR"
echo "Checking if ZIP file exists..."
if [[ ! -f "/mimer/NOBACKUP/groups/naiss2024-22-432/imagenet-object-localization-challenge.zip" ]]; then
    echo "ERROR: ZIP file not found"
    exit 1
fi
echo "ZIP file found"
echo "Extracting ImageNet ZIP to $TMPDIR..."
unzip "/mimer/NOBACKUP/groups/naiss2024-22-432/imagenet-object-localization-challenge.zip" -d $TMPDIR
if [[ $? -ne 0 ]]; then
    echo "ERROR: Extraction failed!"
    exit 1
fi
echo "Extraction complete."
echo "Checking if dataset extracted correctly..."
if [[ ! -d "$TMPDIR/ILSVRC/Data/CLS-LOC/train" ]]; then
    echo "ERROR: Expected dataset directory not found after extraction."
    exit 1
fi
echo "Dataset extracted successfully."

# Create dataset.json
echo "Creating dataset.json..."
python create_dataset_json.py
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to create dataset.json!"
    exit 1
fi
echo "dataset.json created."

echo "Starting dataset processing..."
python /cephyr/users/mircog/Vera/DPDM/dataset_tool.py --source=$TMPDIR/ILSVRC/Data/CLS-LOC/train --dest="/mimer/NOBACKUP/groups/naiss2024-22-432/processed2/imagenet.zip" --resolution=32x32 --transform=center-crop
if [[ $? -ne 0 ]]; then
    echo "ERROR: Dataset processing failed!"
    exit 1
fi
echo "Dataset processing complete."
echo "All steps completed successfully!"
