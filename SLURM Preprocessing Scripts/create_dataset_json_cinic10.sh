#!/bin/bash
#SBATCH -A C3SE2025-1-14 -p vera
#SBATCH --job-name=create_json
#SBATCH --output=create_json_%j.out	
#SBATCH --error=create_json_%j.err  # Added error file
#SBATCH --time=04:00:00
python create_dataset_json_cinic10.py
