#!/bin/bash
#SBATCH --account=C3SE2025-1-14
#SBATCH --partition=vera
#SBATCH --job-name=DPDM
#SBATCH --gpus-per-node=A100:4
#SBATCH --time=7-00:00:00
#SBATCH --output=cinic10_tmp_train_%j.out
#SBATCH --error=cinic10_tmp_train_%j.err

# Unzip CINIC-10 dataset into TMPDIR
unzip -q /mimer/NOBACKUP/groups/naiss2024-22-432/cinic10/cinic10_train_valid.zip -d $TMPDIR

# Print the TMPDIR path to verify before using it in sed
echo "=== TMPDIR path ==="
echo $TMPDIR
# Confirm extraction path (logs to .out file)
echo "=== Checking TMPDIR ==="
ls -lh $TMPDIR
echo "=== Checking TMPDIR/train_valid ==="
ls -lh $TMPDIR/train_valid

# Modify the config file to point to TMPDIR/train_valid
#sed -i "s|data.path:.*|data.path: $TMPDIR/train_valid| /cephyr/users/mircog/Vera/DPDM/configs/cinic10_32/train_eps_10.0.yaml
sed -i "s|path:.*|path: $TMPDIR/train_valid|" /cephyr/users/mircog/Vera/DPDM/configs/cinic10_32/train_eps_10.0.yaml

# Print the updated config file content to verify
echo "=== Updated Config File ==="
cat /cephyr/users/mircog/Vera/DPDM/configs/cinic10_32/train_eps_10.0.yaml

# Run Python script with updated config
apptainer run --nv --bind /cephyr/users/mircog/Vera/DPDM/stylegan3/dataset.py:/workspace/DPDM/stylegan3/dataset.py --bind /cephyr/users/mircog/Vera/DPDM/assets/stats:/workspace/DPDM/assets/stats dpdm.sif /bin/bash -c "cd /workspace/DPDM && python3.9 main.py --mode train --workdir /cephyr/users/mircog/Vera/CINIC_10_${SLURM_JOB_ID} --config /cephyr/users/mircog/Vera/DPDM/configs/cinic10_32/train_eps_10.0.yaml"
