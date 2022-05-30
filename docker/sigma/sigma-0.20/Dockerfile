FROM python:3.8

ARG threads=1

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install make \
        parallel \
        jq
RUN pip install xq yq
RUN mkdir -p /opt/
COPY src/* /opt/
WORKDIR /opt/
RUN tar -xzvf sigma-0.20.tar.gz
WORKDIR /opt/sigma-0.20/tools/
RUN pip3 install --trusted-host pypi.org setuptools
RUN python3 setup.py install
WORKDIR /mnt/
