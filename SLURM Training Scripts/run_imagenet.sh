#!/bin/bash
#SBATCH --account=C3SE2025-1-14
#SBATCH --partition=vera
#SBATCH --job-name=DPDM
#SBATCH --gpus-per-node=A100:4
#SBATCH --time=7-00:00:00
#SBATCH --output=imagenet_pretrain_%j.out
#SBATCH --error=imagenet_pretrain_%j.err

echo "=== [INFO] Starting job at $(date) ==="
echo "=== [INFO] Unzipping dataset ==="
# Unzip ImageNet dataset into TMPDIR
unzip -q /mimer/NOBACKUP/groups/naiss2024-22-432/processed/imagenet.zip -d $TMPDIR
if [ $? -ne 0 ]; then
    echo "!!! [ERROR] Failed to unzip dataset into $TMPDIR"
    exit 1
else
    echo "=== [SUCCESS] Dataset unzipped to $TMPDIR ==="
fi
# Print the TMPDIR path to verify before using it in sed
echo "=== TMPDIR path ==="
echo $TMPDIR
# Confirm extraction path (logs to .out file)
echo "=== Checking TMPDIR ==="
ls -lh $TMPDIR
# Modify the config file to point to TMPDIR/train_valid
sed -i "s|path:.*|path: $TMPDIR|" /cephyr/users/mircog/Vera/DPDM/configs/imagenet_32/train_eps_10.0.yaml
# Print the updated config file content to verify
echo "=== Updated Config File ==="
cat /cephyr/users/mircog/Vera/DPDM/configs/imagenet_32/train_eps_10.0.yaml
echo "=== [INFO] Starting training job ==="
# Run Python script with updated config
apptainer run --nv --bind /cephyr/users/mircog/Vera/DPDM/utils/util.py:/workspace/DPDM/utils/util.py --bind /cephyr/users/mircog/Vera/DPDM/stylegan3/dataset.py:/workspace/DPDM/stylegan3/dataset.py --bind /cephyr/users/mircog/Vera/DPDM/assets/stats:/workspace/DPDM/assets/stats dpdm.sif /bin/bash -c "cd /workspace/DPDM && python3.9 main.py --mode train --workdir /cephyr/users/mircog/Vera/Imagenet_${SLURM_JOB_ID} --config /cephyr/users/mircog/Vera/DPDM/configs/imagenet_32/train_eps_10.0.yaml"
if [ $? -ne 0 ]; then
    echo "!!! [ERROR] Training job failed"
    exit 1
else
    echo "=== [SUCCESS] Training completed successfully ==="
fi
echo "=== [INFO] Job finished at $(date) ==="
