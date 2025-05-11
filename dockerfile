# filepath: Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    make \
    git \
    qemu \
    gdb \
    curl \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /os-scheduler

COPY . /os-scheduler

RUN echo "--- Isi direktori /os-scheduler sebelum make ---" && \
    ls -l /os-scheduler && \
    echo "-------------------------------------------------"

RUN make -C src

CMD ["./scripts/run.sh"]
