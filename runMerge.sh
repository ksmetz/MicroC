#! /bin/bash -login
#SBATCH -J MicroC_Merge
#SBATCH -t 2-00:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1  
#SBATCH -p norm
#SBATCH --mem=2gb
#SBATCH -o "%x-%j.out"

## Exit if any command fails
set -e

## Load required modules
module load python/3.7

## Create and activate virtual environment with requirements
python3 -m venv env && source env/bin/activate && pip3 install -r config/requirements.txt

## Make directory for slurm logs
mkdir -p output/logs_slurm

## Execute buildHIC snakemake workflow
snakemake -j 100 --rerun-incomplete --restart-times 3 -p -s workflows/mergeHIC --latency-wait 500 --cluster-config "config/cluster.yaml" --cluster "sbatch -J {cluster.name} -p {cluster.partition} -t {cluster.time} -c {cluster.cpusPerTask} --mem-per-cpu={cluster.memPerCpu} -N {cluster.nodes} --output {cluster.output} --error {cluster.error} --parsable" --cluster-status ./scripts/status.py

## Success message
echo "Entire workflow completed successfully!"
