FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="peterdiakumis@gmail.com" \
      org.opencontainers.image.description="Bioinformatic workflow tidying" \
      org.opencontainers.image.source="https://github.com/umccr/nemo" \
      org.opencontainers.image.url="https://github.com/umccr/nemo" \
      org.opencontainers.image.documentation="https://umccr.github.io/nemo" \
      org.opencontainers.image.licenses="MIT"

ARG MINIF="miniforge"
ARG MINIF_VERSION="25.3.1-0"
ARG MINIF_URL="https://github.com/conda-forge/${MINIF}/releases/download/${MINIF_VERSION}/Miniforge3-${MINIF_VERSION}-Linux-x86_64.sh"

# install core pkgs, miniforge
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    bash bzip2 curl less wget zip ca-certificates && \
    apt-get clean && \
    curl --silent -L "${MINIF_URL}" -o "${MINIF}.sh" && \
    /bin/bash "${MINIF}.sh" -b -p "/opt/${MINIF}/" && \
    rm "${MINIF}.sh"

# create conda env
ENV PATH="/opt/${MINIF}/bin:$PATH"
ARG CONDA_ENV_DIR="/home/conda_envs"
ARG LOCKFILE="conda-linux-64.lock"
COPY "./deploy/conda/env/lock/${LOCKFILE}" "${CONDA_ENV_DIR}/"
RUN conda create -n "nemo_env" --file "${CONDA_ENV_DIR}/${LOCKFILE}" && \
    conda clean --all --force-pkgs-dirs --yes

# Now copy env to smaller image
FROM quay.io/bioconda/base-glibc-debian-bash:3.1

COPY --from=0 "/opt/miniforge/envs/" "/opt/miniforge/envs/"

# env is activated by default
ARG MINIF="miniforge"
ARG CONDA_ENV_NAME="nemo_env"
ENV PATH="/opt/${MINIF}/envs/${CONDA_ENV_NAME}/bin:${PATH}"
ENV CONDA_PREFIX="/opt/${MINIF}/envs/${CONDA_ENV_NAME}"

CMD [ "nemo.R" ]
