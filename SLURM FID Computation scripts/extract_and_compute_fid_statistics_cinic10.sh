#!/bin/bash
#SBATCH -A C3SE2025-1-14 -p vera
#SBATCH -t 2-00:00:00
#SBATCH --gpus-per-node=A100:1
#SBATCH -o cinic10_fid_%j.txt
#SBATCH -e cinic10_fid_%j.txt

# Load modules
module load CUDA/11.3.1  # Verify with 'module avail cuda'

# Activate virtual environment
source /cephyr/users/mircog/Vera/DPDM/venv/bin/activate

# Work in $TMPDIR
cd $TMPDIR

# Extract CINIC-10.tar.gz
echo "Extracting CINIC-10 at $(date)"
pigz -dc /mimer/NOBACKUP/groups/naiss2024-22-432/cinic10/CINIC-10.tar.gz | tar -xv

# Merge train and valid
echo "Merging train and valid at $(date)"
mkdir -p train_valid
cp -r train/* train_valid/
cp -r valid/* train_valid/

# Run FID computation
echo "Running FID computation at $(date)"
cd /cephyr/users/mircog/Vera/DPDM/
python compute_fid_statistics.py --path $TMPDIR/train_valid --fid_dir assets/stats --file cinic10_train_valid.npz

echo "Job finished at $(date)"
