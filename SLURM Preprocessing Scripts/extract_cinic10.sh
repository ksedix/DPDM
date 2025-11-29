#!/bin/bash
#SBATCH -A C3SE2025-1-14 -p vera
#SBATCH --job-name=extract_cinic10
#SBATCH --output=extract_cinic10_%j.out
#SBATCH --error=extract_cinic10_%j.err
#SBATCH --time=02:00:00
echo "Starting job at $(date)"
# Clean up only specific dirs
echo "Deleting train, valid, test directories at $(date)"
rm -rf train valid test train_valid
echo "Cleanup complete at $(date)"

# Extract with pigz
echo "Starting extraction with pigz at $(date)"
pigz -dc CINIC-10.tar.gz | tar -xv
echo "Extraction complete at $(date)"
# Verify counts
echo "Counting extracted files at $(date)"
find train -type f | wc -l > train_count.txt
find valid -type f | wc -l > valid_count.txt
find test -type f | wc -l > test_count.txt
cat train_count.txt
cat valid_count.txt
cat test_count.txt

# Merge train and valid
echo "Merging train and valid into train_valid at $(date)"
mkdir -p train_valid

cp -r train/* train_valid/

cp -r valid/* train_valid/

find train_valid -type f | wc -l > train_valid_count.txt

cat train_valid_count.txt

echo "Job finished at $(date)"
