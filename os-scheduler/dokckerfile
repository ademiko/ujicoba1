# filepath: Dockerfile
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    git \
    qemu \
    gdb \
    curl \
    vim \
    && apt-get clean

WORKDIR /os-scheduler

COPY . /os-scheduler

RUN make -C src

CMD ["./scripts/run.sh"]
