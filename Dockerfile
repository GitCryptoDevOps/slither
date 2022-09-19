# syntax=docker/dockerfile:1.3
FROM ubuntu:jammy AS python-wheels
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

COPY . /slither

RUN cd /slither && \
    echo pip3 install --no-cache-dir --upgrade pip && \
    pip3 wheel -w /wheels . solc-select pip setuptools wheel


FROM ubuntu:jammy AS final

LABEL name=slither
LABEL src="https://github.com/trailofbits/slither"
LABEL creator=trailofbits
LABEL dockerfile_maintenance=trailofbits
LABEL desc="Static Analyzer for Solidity"

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m slither
USER slither

COPY --chown=slither:slither . /home/slither/slither
WORKDIR /home/slither/slither

ENV PATH="/home/slither/.local/bin:${PATH}"

# no-index ensures we install the freshly-built wheels
RUN --mount=type=bind,target=/mnt,source=/wheels,from=python-wheels \
    pip3 install --user --no-cache-dir --upgrade --no-index --find-links /mnt pip slither-analyzer solc-select

COPY --chown=slither:slither ./install-solc.sh .
RUN ./install-solc.sh

COPY --chown=slither:slither ./run-slither.sh /usr/local/bin/run-slither

