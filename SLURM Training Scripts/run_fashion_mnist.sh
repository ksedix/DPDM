#!/bin/bash
#SBATCH --account=C3SE2025-1-14
#SBATCH --partition=vera
#SBATCH --job-name=DPDM                # Job name
#SBATCH --gpus-per-node=A100:4              # Request 4 H100 GPUs per node
#SBATCH --time=96:00:00                # Set time limit (24 hours)
#SBATCH --output=fashion_mnist_train_%j.out    # Standard output file
#SBATCH --error=fashion_mnist_train_%j.err     # Standard error file

# Run the Python script inside the Apptainer container
#apptainer run --nv dpdm.sif /bin/bash -c cd /workspace/DPDM && python3.9 main.py --mode train --workdir /cephyr/users/mircog/Vera/Fashion_MNIST_${SLURM_JOB_ID} --config /cephyr/users/mircog/Vera/DPDM/configs/fmnist_28/train_eps_1.0.yaml"
apptainer run --nv --bind /cephyr/users/mircog/Vera/DPDM/assets/stats:/workspace/DPDM/assets/stats --bind /cephyr/users/mircog/Vera/toy_data:/workspace/DPDM/toy_data dpdm.sif /bin/bash -c "cd /workspace/DPDM && python3.9 main.py --mode train --workdir /cephyr/users/mircog/Vera/Fashion_MNIST_${SLURM_JOB_ID} --config /cephyr/users/mircog/Vera/DPDM/configs/fmnist_28/train_eps_10.0.yaml"
