#!/bin/bash
#SBATCH --account=C3SE2025-1-14
#SBATCH --partition=vera
#SBATCH --job-name=DPDM
#SBATCH --gpus-per-node=A100:4
#SBATCH --time=7-00:00:00
#SBATCH --output=imagenet_pretrain_zip_%j.out
#SBATCH --error=imagenet_pretrain_zip_%j.err

echo "=== [INFO] Starting job at $(date) ==="
# Run Python script with updated config
apptainer run --nv --bind /cephyr/users/mircog/Vera/DPDM/utils/util.py:/workspace/DPDM/utils/util.py --bind /cephyr/users/mircog/Vera/DPDM/stylegan3/dataset.py:/workspace/DPDM/stylegan3/dataset.py --bind /cephyr/users/mircog/Vera/DPDM/assets/stats:/workspace/DPDM/assets/stats dpdm.sif /bin/bash -c "cd /workspace/DPDM && python3.9 main.py --mode train --workdir /cephyr/users/mircog/Vera/Imagenet_${SLURM_JOB_ID} --config /cephyr/users/mircog/Vera/DPDM/configs/imagenet_32/train_eps_10.0.yaml"
if [ $? -ne 0 ]; then
    echo "!!! [ERROR] Training job failed"
    exit 1
else
    echo "=== [SUCCESS] Training completed successfully ==="
fi
echo "=== [INFO] Job finished at $(date) ==="
