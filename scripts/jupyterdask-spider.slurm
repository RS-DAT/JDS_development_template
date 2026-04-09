#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=06:00:00
#SBATCH --partition=normal
#SBATCH --output=.jupyterdask/%x-%j.out
##SBATCH --reservation=[reservation_name] 
# The line above is commented out. To run with a reservation restore by removing the leading hash character and substituting
# the correct reservation name 


# modify the image bath below to reflect your repository. PAY ATTENTION to lower case spelling!
# As an example consider the image specified for the JDS_development_template repository in the RS-DAT organization below.
# APPTAINER_IMAGE="oras://ghcr.io/[yourGitHubOrganization]/[yourRpository]:latest"

APPTAINER_IMAGE="oras://ghcr.io/rs-dat/jds_development_template:latest"

# Bind all paths from host system within the container
_DIRS=`/usr/bin/ls -1 / | /usr/bin/awk '!/dev/' | /usr/bin/sed 's/^/\//g' `
export APPTAINER_BIND=`echo ${_DIRS} | /usr/bin/sed 's/ /,/g' `

# Use Python interpreter from the container image
PYTHON="apptainer run ${APPTAINER_IMAGE} python"

# Configure default Dask cluster settings
export DASK_DISTRIBUTED__DASHBOARD__LINK="/proxy/{port}/status"
export DASK_LABEXTENSION__FACTORY__MODULE="dask_jobqueue"
export DASK_LABEXTENSION__FACTORY__CLASS="SLURMCluster"
export DASK_JOBQUEUE__SLURM__DEATH_TIMEOUT=60
export DASK_JOBQUEUE__SLURM__PYTHON=${PYTHON}
# run without reservation
export DASK_JOBQUEUE__SLURM__JOB_EXTRA_DIRECTIVES="['--output', '.jupyterdask/%x-%j.out']"
# run with reservation
#export DASK_JOBQUEUE__SLURM__JOB_EXTRA_DIRECTIVES="['--output', '.jupyterdask/%x-%j.out', '--reservation', '[reservation_name]']"
# The below can be adpated to change the setting of dask workers
export DASK_JOBQUEUE__SLURM__PROCESSES=1
export DASK_JOBQUEUE__SLURM__CORES=2
export DASK_JOBQUEUE__SLURM__MEMORY="24GiB"
export DASK_JOBQUEUE__SLURM__WALLTIME="02:00:00"
export DASK_JOBQUEUE__SLURM__QUEUE="normal"
export DASK_JOBQUEUE__SLURM__LOCAL_DIRECTORY="\$TMPDIR"

# Configure dCache access
export FSSPEC_DCACHE_API_URL="https://dcacheview.grid.surfsara.nl:22880/api/v1"
export FSSPEC_DCACHE_WEBDAV_URL="https://webdav.grid.surfsara.nl:2880"
export FSSPEC_DCACHE_TOKEN="<MACAROON>"

# Start the Jupyter server
${PYTHON} \
  -m jupyterlab \
  --no-browser \
  --port=`shuf -i 8400-9400 -n 1` \
  --ip=`hostname -s`
