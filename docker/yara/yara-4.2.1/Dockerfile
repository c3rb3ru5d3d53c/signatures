FROM ubuntu:20.04

ARG threads=1

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install automake \
        libssl-dev \
        libmagic-dev \
        libtool \
        make \
        gcc \
        wget \
        curl \
        python3 \
        python3-dev \
        python3-setuptools \
              libprotobuf-dev \
              pkg-config \
           parallel
RUN mkdir -p /opt/
COPY src/* \
     /opt/
WORKDIR /opt/
RUN tar -xzvf yara-4.2.1.tar.gz
WORKDIR /opt/yara-4.2.1/
RUN ./bootstrap.sh
RUN ./configure --enable-macho --enable-magic --enable-dex
RUN make -j ${threads}
RUN make install
RUN ldconfig
WORKDIR /opt/
# RUN tar -xzvf yara-python-4.2.1.tar.gz
# WORKDIR /opt/yara-python-4.2.1/
# RUN python3 setup.py build --dynamic-linking
# RUN python3 setup.py install
