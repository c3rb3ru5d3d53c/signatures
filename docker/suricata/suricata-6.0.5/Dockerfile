FROM ubuntu:20.04

ARG threads=1

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install python-dev \
    parallel \
    bsdmainutils \
    git \
    cmake \
    ragel \
    make \
    libmagic-dev \
    libjansson-dev \
    libnss3-dev \
    libgeoip-dev \
    liblua5.1-dev \
    libluajit-5.1-dev \
    libhiredis-dev \
    libboost-dev \
    libpcre3-dev \
    build-essential \
    libpcap-dev \
    libnet1-dev \
    libyaml-0-2 \
    libyaml-dev \
    liblz4-dev \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    libcap-ng-dev \
    libcap-ng0 \
    libevent-dev \
    python-yaml \
    rustc \
    cargo
RUN mkdir -p /opt/
COPY src/* /opt/
WORKDIR /opt/
RUN tar -xzvf suricata-6.0.5.tar.gz
WORKDIR /opt/suricata-6.0.5/
RUN git clone https://github.com/OISF/libhtp
RUN cargo install --root /usr/local cbindgen
RUN ./autogen.sh
RUN ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-luajit --enable-rust
RUN make -j ${threads}
RUN make install
RUN make install-conf
WORKDIR /mnt/
