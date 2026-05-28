# JDS_development_template
Template repository for generating (development/exploration stage) repositories for use with jupyterdask tool (see [JupyterDaskOnSlurm](https://github.com/RS-DAT/JupyterDaskOnSLURM))

This repository provides a simple template to build containerized Python environments for use with the jupyterdask tool. This is to address the challenge that conventional Python environments are not suitable for HPC infrastructures with distributed filesystems, e.g. SURF SPIDER.

The users can modify the `environment.yml` file to specify the dependencies needed for their project, and the GitHub Actions workflow will take care of building and pushing the container image to the GitHub Container Registry. The example SLURM submission script provided in `scripts/jupyterdask-spider.slurm` will use the built container image to run a Jupyter server on the SURF SPIDER HPC cluster. 

## Step-by-step guide to use this template on SURF SPIDER HPC cluster

1. Click the "Use this template" button on the GitHub repository page to create a new repository based on this template. You can create a new repository under your personal GitHub account or within an organization that you belong to.

2. In your new repository, update the `environment.yml` file to include the necessary dependencies for your project. The file is already pre-populated with some common dependencies, so you can add or remove packages as needed. After modifying the `environment.yml` file.

3. Commit and push the changes to your repository. A GitHub Actions workflow will automatically build a new container image based on the updated `environment.yml` file and push it to the GitHub Container Registry. The link to the container image will be in the format `ghcr.io/[yourGitHubOrganization]/[yourRepository]:latest`.

4. Install the `jupyterdask` CLI tool on your local machine if you haven't already. Please remember to install it in an independent environment (e.g., `venv`), here we give an example using [`uv`](https://docs.astral.sh/uv/):

```bash
uv venv
source .venv/bin/activate
pip install -e "git+https://github.com/RS-DAT/JupyterDaskOnSLURM.git#egg=jupyterdask&subdirectory=tools/jupyterdask"
```

5. Modify the `scripts/jupyterdask-spider.slurm` file. This is the SLURM submission script that will be used by the `jupyterdask` CLI tool to submit jobs to the HPC cluster. Please pay attention to the following lines:
    - `APPTAINER_IMAGE="oras://ghcr.io/[yourGitHubOrganization]/[yourRpository]:latest"`: Update this line to point to the container image that was built and pushed to the GitHub Container Registry in step 2. Replace `[yourGitHubOrganization]` and `[yourRepository]` with the appropriate values for your GitHub account and repository.
    - `export FSSPEC_DCACHE_TOKEN="<MACAROON>"`: Update this with the macaroons token if you want to use the dcache filesystem. You can leave this as is if you do not want to use dcache.
    - Other SLURM job parameters (e.g., `--cpus-per-task`, `--time`, etc.) can also be modified according to your needs.

```warning
WARNING

If you have updated `export FSSPEC_DCACHE_TOKEN="<MACAROON>"` with a valid token, please make sure not committing and pushing the updated `jupyterdask-spider.slurm` file to your repository, as this may expose your token to the public.
```

6. Now you can use the `jupyterdask` CLI tool to submit the configured SLURM job to the HPC cluster:

```bash
jupyterdask -i jupyterdask -i /path/to/ssh/key --template /path/to/jupyterdask-spider.slurm --run <YOUR_USERNAME>@spider.surf.nl
```

After running the above command, `jupyterdask` will submit the job to the HPC SLURM scheduler. When the job starts running, you will see a link to the forwarded Jupyter server in the output of the command. You can open this link in your web browser to access the Jupyter server.
